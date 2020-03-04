//
//  WireGuardSettingsViewController.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 10/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit
import SafariServices

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
        
        if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        }
        
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
    
    // MARK: - @IBActions -
    
    @IBAction func dismissViewController(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }
    
    // MARK: - Methods -
    
    func logOut(deleteSession: Bool = true) {
        if deleteSession {
            let sessionManager = SessionManager()
            sessionManager.delegate = self
            sessionManager.deleteSession()
        }
        
        if UserDefaults.shared.networkProtectionEnabled {
            UserDefaults.clearSession()
        }
        
        Application.shared.connectionManager.removeStatusChangeUpdates()
        Application.shared.connectionManager.disconnectShortcut()
        Application.shared.connectionManager.removeAll()
        Application.shared.authentication.logOut()
    }
    
    func openTermsOfService() {
        let viewController = NavigationManager.getStaticWebViewController(resourceName: "tos", screenTitle: "Terms of Service")
        navigationController?.show(viewController, sender: nil)
    }
    
    func openPrivacyPolicy() {
        let viewController = NavigationManager.getStaticWebViewController(resourceName: "privacy-policy", screenTitle: "Privacy Policy")
        navigationController?.show(viewController, sender: nil)
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
        
        guard let url = URL(string: stringURL) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    func showSubscriptionActivatedAlert(serviceStatus: ServiceStatus) {
        showAlert(
            title: "Thank you!",
            message: "Service was successfuly upgraded.\nService active until: " + serviceStatus.activeUntilString(),
            handler: { _ in
                self.navigationController?.dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name.SubscriptionActivated, object: nil)
                }
        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    func deleteSessionStart() {}
    func deleteSessionSuccess() {}
    func deleteSessionFailure() {}
    func deleteSessionSkip() {}
    func sessionStatusSuccess() {}
    func sessionStatusNotFound() {}
    func sessionStatusExpired() {}
    func sessionStatusFailure() {}
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
            if #available(iOS 13.0, *) {
                let viewController = NavigationManager.getLoginViewController(modalPresentationStyle: .automatic)
                presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
                present(viewController, animated: true, completion: nil)
            } else {
                let viewController = NavigationManager.getLoginViewController()
                presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
                present(viewController, animated: true, completion: nil)
            }
            
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
    
    func evaluateIsServiceActive() -> Bool {
        guard Application.shared.serviceStatus.isActive else {
            let viewController = NavigationManager.getSubscriptionViewController()
            viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
            present(viewController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func evaluateMultiHopCapability(_ sender: Any) -> Bool {
        guard Application.shared.serviceStatus.isEnabled(capability: .multihop) else {
            if Application.shared.serviceStatus.isOnFreeTrial {
                showAlert(title: "", message: "MultiHop is supported only on IVPN Pro plan")
                return false
            }
            
            showActionSheet(title: "MultiHop is supported only on IVPN Pro plan", actions: ["Switch plan"], sourceView: sender as! UIView) { index in
                switch index {
                case 0:
                    self.manageSubscription()
                default:
                    break
                }
            }
            
            return false
        }
        
        return true
    }
    
    func manageSubscription() {
        if !Application.shared.serviceStatus.isActive {
            present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
            return
        }
        
        if Application.shared.serviceStatus.isAppStoreSubscription() {
            UIApplication.manageSubscription()
        } else {
            if let upgradeToUrl = Application.shared.serviceStatus.upgradeToUrl {
                openWebPage(upgradeToUrl)
            }
        }
    }
    
    func presentSettingsScreen() {
        let viewController = NavigationManager.getSettingsViewController()
        viewController.presentationController?.delegate = self as? UIAdaptivePresentationControllerDelegate
        present(viewController, animated: true, completion: nil)
    }
    
}
