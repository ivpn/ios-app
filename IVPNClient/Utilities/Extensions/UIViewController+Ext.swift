//
//  UIViewController+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-10.
//  Copyright (c) 2020 Privatus Limited.
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
import WebKit
import MessageUI
import WidgetKit

extension UIDevice {
    
    var hasNotch: Bool {
        let bottom = UIWindow.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
}

extension UIViewController {
    
    // MARK: - Properties -
    
    var isPresentedModally: Bool {
        if let navigationController = navigationController {
            if navigationController.viewControllers.first != self {
                return false
            }
        }
        
        if presentingViewController != nil {
            return true
        }
        
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
    
    // MARK: - @IBActions -
    
    @IBAction func dismissViewController(_ sender: Any) {
        if let presentationController = navigationController?.presentationController {
            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        }
        
        navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Methods -
    
    func logOut(deleteSession: Bool = true, deleteSettings: Bool = false) {
        Application.shared.connectionManager.removeAll()
        Application.shared.authentication.logOut(deleteSettings: deleteSettings)
        NotificationCenter.default.post(name: Notification.Name.VPNConfigurationDisabled, object: nil)
        NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        
        if deleteSession {
            let sessionManager = SessionManager()
            sessionManager.delegate = self
            sessionManager.deleteSession()
        }
    }
    
    func openTermsOfService() {
        openWebPage("https://www.ivpn.net/tos-mobile-app/")
    }
    
    func openPrivacyPolicy() {
        openWebPage("https://www.ivpn.net/privacy-mobile-app/")
    }
    
    func registerUserActivity(type: String, title: String) {
        let activity = NSUserActivity(activityType: type)
        activity.title = title
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        
        userActivity = activity
        userActivity?.becomeCurrent()
    }
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func openWebPage(_ stringURL: String) {
        guard UIApplication.isValidURL(urlString: stringURL) else {
            showErrorAlert(title: "Error", message: "The specified URL has an unsupported scheme. Only HTTP and HTTPS URLs are supported.")
            return
        }
        
        guard let url = URL(string: stringURL) else {
            return
        }
        
        let request = URLRequest(url: url)
        let webView = WKWebView()
        present(NavigationManager.getWebkitViewController(webView: webView), animated: true) {
            webView.load(request)
        }
    }
    
    func showSubscriptionActivatedAlert(serviceStatus: ServiceStatus, completion: (() -> Void)? = nil) {
        showAlert(
            title: "Thank you!",
            message: "The payment was successfully processed.\nService is active until: " + serviceStatus.activeUntilString(),
            handler: { _ in
                if let completion = completion {
                    completion()
                }
        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func selectNetworkTrust(network: Network, sourceView: UIView, completion: @escaping (String) -> Void) {
        var collection = NetworkTrust.allCasesNormal
        
        if network.isDefault {
            collection = NetworkTrust.allCasesDefault
        }
        
        let actions = collection.map { $0.rawValue }
        
        showActionSheet(image: nil, selected: network.trust, largeText: true, centered: true, title: "Network Trust", actions: actions, sourceView: sourceView) { index in
            guard index > -1, actions[index] != network.trust else {
                return
            }
            
            completion(actions[index])
        }
    }
    
    func evaluateReconnect(sender: UIView) {
        if !Application.shared.connectionManager.status.isDisconnected() {
            showReconnectPrompt(sourceView: sender) {
                Application.shared.connectionManager.reconnect()
            }
        }
    }
    
    func showReconnectPrompt(sourceView: UIView, confirmed: @escaping () -> Void) {
        guard !UserDefaults.shared.notAskToReconnect else {
            confirmed()
            return
        }
        
        showActionSheet(title: "To apply the new settings, IVPN needs to be reconnected.", actions: ["Reconnect", "Reconnect + Don't ask next time"], sourceView: sourceView, disableDismiss: true) { index in
            switch index {
            case 0:
                confirmed()
            case 1:
                UserDefaults.shared.setValue(true, forKey: UserDefaults.Key.notAskToReconnect)
                confirmed()
            default:
                break
            }
        }
    }
    
    func showDisableVPNPrompt(sourceView: UIView, confirmed: @escaping () -> Void) {
        showActionSheet(title: "VPN connection is active. Changing this setting will turn off the current VPN connection.", actions: ["Continue"], sourceView: sourceView, disableDismiss: true) { index in
            switch index {
            case 0:
                confirmed()
            default:
                break
            }
        }
    }
    
    @objc func showResolvedDNSError() {
        showErrorAlert(title: "Error", message: "Failed to resolve IP addresses for DNS server")
    }
    
    func showWireGuardKeysMissingError() {
        showErrorAlert(title: "Error", message: "Failed to connect to VPN - WireGuard keys are missing. Please generate new keys in the Settings or try to connect to VPN manually.")
    }
    
    func evaluatePasscode() -> Bool {
        guard UIDevice.isPasscodeSet() else {
            showAlert(title: "Passcode is disabled", message: "Please enable Passcode in the iOS Settings")
            return false
        }
        
        return true
    }
    
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            
            return tab.topMostViewController()
        }
        
        return self.presentedViewController!.topMostViewController()
    }
    
}

// MARK: - Presenter -

extension UIViewController {
    
    func evaluateIsServiceActive() -> Bool {
        guard Application.shared.serviceStatus.isActive else {
            if !Application.shared.serviceStatus.isLegacyAccount() {
                let viewController = NavigationManager.getSubscriptionViewController()
                viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
                present(viewController, animated: true, completion: nil)
            }
            return false
        }
        
        return true
    }
    
    func deviceCanMakePurchases() -> Bool {
        guard IAPManager.shared.canMakePurchases else {
            showAlert(title: "Error", message: "In-App Purchases are not available on your device.")
            return false
        }
        
        return true
    }
    
}

extension UIViewController: AppKeyManagerDelegate {
    func setKeyStart() {}
    func setKeySuccess() {}
    func setKeyFail() {}
}

extension UIViewController: SessionManagerDelegate {
    func createSessionStart() {}
    func createSessionSuccess() {}
    func createSessionFailure(error: Any?) {}
    func createSessionTooManySessions(error: Any?) {}
    func createSessionAuthenticationError() {}
    func createSessionServiceNotActive() {}
    func createSessionAccountNotActivated(error: Any?) {}
    func deleteSessionStart() {}
    func deleteSessionSuccess() {}
    func deleteSessionFailure() {}
    func deleteSessionSkip() {}
    func sessionStatusSuccess() {}
    func sessionStatusNotFound() {}
    func sessionStatusExpired() {}
    func sessionStatusFailure() {}
    func twoFactorRequired(error: Any?) {}
    func twoFactorIncorrect(error: Any?) {}
    func captchaRequired(error: Any?) {}
    func captchaIncorrect(error: Any?) {}
}

// MARK: - Presenter -

extension UIViewController {
    
    func evaluateIsNetworkReachable() -> Bool {
        guard NetworkManager.shared.isNetworkReachable else {
            showAlert(title: "Connection error", message: "Please check your Internet connection and try again.")
            return false
        }
        
        return true
    }
    
    func evaluateIsLoggedIn() -> Bool {
        guard Application.shared.authentication.isLoggedIn else {
            let viewController = NavigationManager.getLoginViewController()
            viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
            present(viewController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func evaluateHasUserConsent() -> Bool {
        guard UserDefaults.shared.hasUserConsent else {
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func evaluateMultiHopCapability(_ sender: Any) -> Bool {
        guard Application.shared.serviceStatus.isEnabled(capability: .multihop) else {
            showAlert(title: "", message: "MultiHop is supported only on IVPN Pro plan")
            return false
        }
        
        return true
    }
    
    func evaluateProtocolForMultiHop() -> Bool {
        if Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "Change protocol to WireGuard or OpenVPN", message: "For Multi-Hop connection you must select WireGuard or OpenVPN protocol.") { _ in
            }
            return false
        }
        
        return true
    }
    
    func evaluateMailCompose() -> Bool {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Cannot send e-mail", message: "Your device cannot send e-mail. Please check e-mail configuration and try again.")
            return false
        }
        
        return true
    }
    
    func presentSettingsScreen() {
        let viewController = NavigationManager.getSettingsViewController()
        viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
        present(viewController, animated: true, completion: nil)
    }
    
    func presentAccountScreen() {
        let viewController = NavigationManager.getAccountViewController()
        viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
        present(viewController, animated: true, completion: nil)
    }
    
}
