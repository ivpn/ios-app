//
//  LoginViewController.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 7/12/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

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
    
    // MARK: - @IBActions -
    
    @IBAction func loginToAccount(_ sender: AnyObject) {
        view.endEditing(true)
        startLoginProcess()
    }
    
    @IBAction func createAccount(_ sender: AnyObject) {
        guard KeyChain.username == nil else {
            present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
            return
        }
        
        let request = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup)
        ApiService.shared.request(request) { [weak self] (result: Result<GeoLookup>) in
            guard let self = self else { return }
            
            switch result {
            case .success:
                KeyChain.username = "ivpnXXXXXXXX"
                self.present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
            case .failure:
                break
            }
        }
    }
    
    @IBAction func openScanner(_ sender: AnyObject) {
        present(NavigationManager.getScannerViewController(delegate: self), animated: true)
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
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.NewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ForceNewSession, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.TermsOfServiceAgreed, object: nil)
    }
    
    @objc func newSession() {
        startLoginProcess()
    }
    
    @objc func forceNewSession() {
        startLoginProcess(force: true)
    }
    
    @objc func termsOfServiceAgreed() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.TermsOfServiceAgreed, object: nil)
        let _ = evaluateIsServiceActive()
    }
    
    // MARK: - Methods -
    
    private func startLoginProcess(force: Bool = false) {
        guard !loginProcessStarted else { return }
        
        let username = (self.userName.text ?? "").trim()
        
        loginProcessStarted = true
        
        guard ServiceStatus.isValid(username: username) else {
            loginProcessStarted = false
            showUsernameError()
            return
        }
        
        KeyChain.username = username
        
        sessionManager.createSession(force: force)
    }
    
    private func showUsernameError() {
        showErrorAlert(
            title: "You entered an invalid account ID",
            message: "Your account ID starts with the letters 'ivpn' and can be found in the welcome email sent to you on signup. You cannot use your email address."
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
        ProgressIndicator.shared.showIn(view: view)
    }
    
    override func createSessionSuccess() {
        ProgressIndicator.shared.hide()
        loginProcessStarted = false
        
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
        })
    }
    
    override func createSessionServiceNotActive() {
        ProgressIndicator.shared.hide()
        loginProcessStarted = false
        
        let viewController = NavigationManager.getSubscriptionViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    override func createSessionTooManySessions(error: Any?) {
        ProgressIndicator.shared.hide()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        
        if let error = error as? ErrorResultSessionNew {
            if let data = error.data {
                if data.upgradable {
                    NotificationCenter.default.addObserver(self, selector: #selector(newSession), name: Notification.Name.NewSession, object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(forceNewSession), name: Notification.Name.ForceNewSession, object: nil)
                    UserDefaults.shared.set(data.limit, forKey: UserDefaults.Key.sessionsLimit)
                    UserDefaults.shared.set(data.upgradeToUrl, forKey: UserDefaults.Key.upgradeToUrl)
                    UserDefaults.shared.set(data.isAppStoreSubscription(), forKey: UserDefaults.Key.subscriptionPurchasedOnDevice)
                    present(NavigationManager.getUpgradePlanViewController(), animated: true, completion: nil)
                    return
                }
            }
        }
        
        showCreateSessionAlert(message: "You've reached the maximum number of connected devices")
    }
    
    override func createSessionAuthenticationError() {
        ProgressIndicator.shared.hide()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        showErrorAlert(title: "Error", message: "Account ID is incorrect")
    }
    
    override func createSessionFailure(error: Any?) {
        var message = "There was an error creating a new session"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        ProgressIndicator.shared.hide()
        Application.shared.authentication.removeStoredCredentials()
        loginProcessStarted = false
        showErrorAlert(title: "Error", message: message)
    }
    
    func showCreateSessionAlert(message: String) {
        showActionSheet(title: message, actions: ["Log out from all other devices", "Try again"], sourceView: self.userName) { index in
            switch index {
            case 0:
                self.startLoginProcess(force: true)
            case 1:
                self.startLoginProcess()
            default:
                break
            }
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
        startLoginProcess()
    }
    
}
