//
//  LoginViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-07-12.
//  Copyright (c) 2023 IVPN Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import JGProgressHUD
import WidgetKit

class LoginViewController: UIViewController {

    // MARK: - @IBOutlets -
    
    @IBOutlet weak var userName: UITextField! {
        didSet {
            userName.delegate = self
        }
    }
    
    @IBOutlet weak var scannerButton: UIButton! {
        didSet {
            scannerButton.isHidden = !UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    // MARK: - Properties -
    
    private lazy var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.delegate = self
        return sessionManager
    }()
    
    private var loginProcessStarted = false
    private let hud = JGProgressHUD(style: .dark)
    private var actionType: ActionType = .login
    private var loginConfirmation = LoginConfirmation()
    
    // MARK: - @IBActions -
    
    @IBAction func loginToAccount(_ sender: AnyObject) {
        guard evaluatePasscode() else {
            return
        }
        
        guard UserDefaults.shared.hasUserConsent else {
            actionType = .login
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return
        }
        
        view.endEditing(true)
        startLoginProcess()
    }
    
    @IBAction func createAccount(_ sender: AnyObject) {
        guard evaluatePasscode() else {
            return
        }
        
        guard UserDefaults.shared.hasUserConsent else {
            actionType = .signup
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return
        }
        
        startSignupProcess()
    }
    
    @IBAction func openScanner(_ sender: AnyObject) {
        present(NavigationManager.getScannerViewController(delegate: self), animated: true)
    }
    
    @IBAction func restorePurchases(_ sender: AnyObject) {
        guard evaluatePasscode() else {
            return
        }
        
        guard deviceCanMakePurchases() else {
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Restoring purchases..."
        hud.show(in: (navigationController?.view)!)
        
        IAPManager.shared.restorePurchases { account, error in
            self.hud.dismiss()
            
            if let error = error {
                self.showErrorAlert(title: "Restore failed", message: error.message)
                return
            }
            
            if account != nil {
                self.userName.text = account?.accountId
                self.sessionManager.createSession()
            }
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "loginScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        addObservers()
        hideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        navigationController?.navigationBar.setNeedsLayout()
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(termsOfServiceAgreed), name: Notification.Name.TermsOfServiceAgreed, object: nil)
    }
    
    @objc func newSession() {
        if let confirmation = loginConfirmation.confirmation {
            startLoginProcess(confirmation: confirmation)
            return
        }
        
        if let captcha = loginConfirmation.captcha, let captchaId = loginConfirmation.captchaId {
            startLoginProcess(captcha: captcha, captchaId: captchaId)
            return
        }
        
        startLoginProcess()
    }
    
    @objc func forceNewSession() {
        if let confirmation = loginConfirmation.confirmation {
            startLoginProcess(force: true, confirmation: confirmation)
            return
        }
        
        if let captcha = loginConfirmation.captcha, let captchaId = loginConfirmation.captchaId {
            startLoginProcess(force: true, captcha: captcha, captchaId: captchaId)
            return
        }
        
        startLoginProcess(force: true)
    }
    
    @objc func termsOfServiceAgreed() {
        switch actionType {
        case .login:
            loginToAccount(self)
        case .signup:
            createAccount(self)
        }
    }
    
    // MARK: - Methods -
    
    private func startLoginProcess(force: Bool = false, confirmation: String? = nil, captcha: String? = nil, captchaId: String? = nil) {
        guard !loginProcessStarted else { return }
        
        let username = (self.userName.text ?? "").trim()
        
        loginProcessStarted = true
        
        guard ServiceStatus.isValid(username: username) else {
            loginProcessStarted = false
            showUsernameError()
            return
        }
        
        sessionManager.createSession(force: force, username: username, confirmation: confirmation, captcha: captcha, captchaId: captchaId)
    }
    
    private func startSignupProcess() {
        if KeyChain.tempUsername != nil {
            present(NavigationManager.getCreateAccountViewController(), animated: true, completion: nil)
            return
        }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Creating new account..."
        hud.show(in: (navigationController?.view)!)
        
        let request = ApiRequestDI(method: .post, endpoint: Config.apiAccountNew, params: [URLQueryItem(name: "product_name", value: "IVPN Standard")])
        
        ApiService.shared.requestCustomError(request) { [weak self] (result: ResultCustomError<Account, ErrorResult>) in
            guard let self = self else { return }
            
            self.hud.dismiss()
            
            switch result {
            case .success(let account):
                KeyChain.tempUsername = account.accountId
                self.present(NavigationManager.getCreateAccountViewController(), animated: true, completion: nil)
            case .failure(let error):
                self.showErrorAlert(title: "Error", message: error?.message ?? "There was a problem with creating a new account.")
            }
        }
    }
    
    private func showUsernameError() {
        showErrorAlert(
            title: "You entered an invalid account ID",
            message: "Your account ID has to be in 'i-XXXX-XXXX-XXXX' or 'ivpnXXXXXXXX' format. You can find it on other devices where you are logged in and in the client area of the IVPN website."
        )
    }
    
    @objc private func subscriptionDismissed() {
        if Application.shared.authentication.isLoggedIn {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
            })
        }
    }
    
    @objc private func subscriptionActivated() {
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
        })
    }
    
}

// MARK: - SessionManagerDelegate -

extension LoginViewController {
    
    override func createSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Creating new session..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func createSessionSuccess() {
        hud.dismiss()
        loginProcessStarted = false
        loginConfirmation.clear()
        KeyChain.username = (self.userName.text ?? "").trim()
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
            NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
        })
    }
    
    override func createSessionServiceNotActive() {
        hud.dismiss()
        loginProcessStarted = false
        loginConfirmation.clear()
        
        KeyChain.username = (self.userName.text ?? "").trim()
        
        guard !Application.shared.serviceStatus.isLegacyAccount() else {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
            })
            return
        }
        
        let viewController = NavigationManager.getSubscriptionViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    override func createSessionAccountNotActivated(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        loginConfirmation.clear()
        
        KeyChain.tempUsername = (self.userName.text ?? "").trim()
        Application.shared.authentication.removeStoredCredentials()
        
        let viewController = NavigationManager.getSelectPlanViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    override func createSessionTooManySessions(error: Any?) {
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        showTooManySessionsAlert(error: error as? ErrorResultSessionNew)
    }
    
    override func createSessionAuthenticationError() {
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        loginConfirmation.clear()
        showErrorAlert(title: "Error", message: "Account ID is incorrect")
    }
    
    override func createSessionFailure(error: Any?) {
        var message = "There was an error creating a new session"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        loginConfirmation.clear()
        showErrorAlert(title: "Error", message: message)
    }
    
    override func twoFactorRequired(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        loginConfirmation.clear()
        present(NavigationManager.getTwoFactorViewController(delegate: self), animated: true)
    }
    
    override func twoFactorIncorrect(error: Any?) {
        var message = "Unknown error occurred"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        loginProcessStarted = false
        loginConfirmation.clear()
        showErrorAlert(title: "Error", message: message)
    }
    
    override func captchaRequired(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        loginConfirmation.clear()
        presentCaptchaScreen(error: error)
    }
    
    override func captchaIncorrect(error: Any?) {
        hud.dismiss()
        loginProcessStarted = false
        loginConfirmation.clear()
        presentCaptchaScreen(error: error)
    }
    
    private func showTooManySessionsAlert(error: ErrorResultSessionNew?) {
        let message = "You've reached the maximum number of connected devices"
        
        // Default
        guard let error = error, let data = error.data else {
            showActionSheet(title: message, actions: [
                "Log out from all devices",
                "Retry"
            ], cancelAction: "Cancel login", sourceView: self.userName) { [self] index in
                switch index {
                case 0:
                    forceNewSession()
                case 1:
                    newSession()
                default:
                    break
                }
            }
            
            return
        }
        
        let service = ServiceType.getType(currentPlan: data.currentPlan)
        
        // Device Management enabled, Pro plan
        if data.deviceManagement && service == .pro {
            showActionSheet(title: message, actions: [
                "Log out from all devices",
                "Visit Device Management",
                "Retry",
            ], cancelAction: "Cancel login", sourceView: self.userName) { [self] index in
                switch index {
                case 0:
                    forceNewSession()
                case 1:
                    openWebPageInBrowser(data.deviceManagementUrl)
                case 2:
                    newSession()
                default:
                    break
                }
            }
            
            return
        }
        
        // Device Management disabled, Pro plan
        if !data.deviceManagement && service == .pro {
            showActionSheet(title: message, actions: [
                "Log out from all devices",
                "Enable Device Management"
            ], cancelAction: "Cancel login", sourceView: self.userName) { [self] index in
                switch index {
                case 0:
                    forceNewSession()
                case 1:
                    openWebPageInBrowser(data.deviceManagementUrl)
                default:
                    break
                }
            }
            
            return
        }
        
        // Device Management enabled, Standard plan
        if data.deviceManagement && service == .standard {
            showActionSheet(title: message, actions: [
                "Log out from all devices",
                "Visit Device Management",
                "Retry",
                "Upgrade for 7 devices"
            ], cancelAction: "Cancel login", sourceView: self.userName) { [self] index in
                switch index {
                case 0:
                    forceNewSession()
                case 1:
                    openWebPageInBrowser(data.deviceManagementUrl)
                case 2:
                    newSession()
                case 3:
                    openWebPageInBrowser(data.upgradeToUrl)
                default:
                    break
                }
            }
            
            return
        }
        
        // Device Management disabled, Standard plan
        if !data.deviceManagement && service == .standard {
            showActionSheet(title: message, actions: [
                "Log out from all devices",
                "Enable Device Management",
                "Upgrade for 7 devices"
            ], cancelAction: "Cancel login", sourceView: self.userName) { [self] index in
                switch index {
                case 0:
                    forceNewSession()
                case 1:
                    openWebPageInBrowser(data.deviceManagementUrl)
                case 2:
                    openWebPageInBrowser(data.upgradeToUrl)
                default:
                    break
                }
            }
            
            return
        }
    }
    
    private func presentCaptchaScreen(error: Any?) {
        if let error = error as? ErrorResultSessionNew, let imageData = error.captchaImage, let captchaId = error.captchaId {
            present(NavigationManager.getCaptchaViewController(delegate: self, imageData: imageData, captchaId: captchaId), animated: true)
        }
    }
    
}

// MARK: - UITextFieldDelegate -

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userName.resignFirstResponder()
        startLoginProcess()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension LoginViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if Application.shared.authentication.isLoggedIn {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
            })
        }
    }
    
}

// MARK: - ScannerViewControllerDelegate -

extension LoginViewController: ScannerViewControllerDelegate {
    
    func qrCodeFound(code: String) {
        userName.text = code
        
        guard evaluatePasscode() else {
            return
        }
        
        guard UserDefaults.shared.hasUserConsent else {
            DispatchQueue.async {
                self.actionType = .login
                self.present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            }
            
            return
        }
        
        startLoginProcess()
    }
    
}

// MARK: - TwoFactorViewControllerDelegate -

extension LoginViewController: TwoFactorViewControllerDelegate {
    
    func codeSubmitted(code: String) {
        loginConfirmation.confirmation = code
        startLoginProcess(confirmation: code)
    }
    
}

// MARK: - CaptchaViewControllerDelegate -

extension LoginViewController: CaptchaViewControllerDelegate {
    
    func captchaSubmitted(code: String, captchaId: String) {
        loginConfirmation.captcha = code
        loginConfirmation.captchaId = captchaId
        startLoginProcess(captcha: code, captchaId: captchaId)
    }
    
}

extension LoginViewController {
    
    enum ActionType {
        case login
        case signup
    }
    
}
