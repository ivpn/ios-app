//
//  AppDelegate.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-09-29.
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

@UIApplicationMain

class AppDelegate: UIResponder {
    
    // MARK: - Properties -
    
    var window: UIWindow?
    
    private lazy var securityWindow: UIWindow = {
        let screen = UIScreen.main
        let window = UIWindow(frame: screen.bounds)
        let storyBoard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "launchScreen")
        viewController.view.alpha = 0
        window.screen = screen
        window.rootViewController = viewController
        window.windowLevel = .alert
        return window
    }()
    
    // MARK: - Methods -
    
    private func evaluateUITests() {
        // When running the application for UI Testing we need to remove all the stored data so we can start testing the clear app
        // It is impossible to access the KeyChain from the UI test itself as the test runs in different process
        
        if ProcessInfo.processInfo.arguments.contains("-UITests") {
            Application.shared.authentication.removeStoredCredentials()
            Application.shared.serviceStatus.isActive = false
            KeyChain.sessionToken = nil
            UserDefaults.clearSession()
            UserDefaults.shared.removeObject(forKey: UserDefaults.Key.hasUserConsent)
            UserDefaults.standard.set(true, forKey: "-UITests")
        }
        
        if ProcessInfo.processInfo.arguments.contains("-authenticated") {
            KeyChain.sessionToken = "token"
            KeyChain.username = "ivpnXXXXXXXX"
        }
        
        if ProcessInfo.processInfo.arguments.contains("-activeService") {
            Application.shared.serviceStatus.isActive = true
        }
        
        if ProcessInfo.processInfo.arguments.contains("-hasUserConsent") {
            UserDefaults.shared.set(true, forKey: UserDefaults.Key.hasUserConsent)
        }
    }
    
    private func registerUserDefaults() {
        UserDefaults.registerUserDefaults()
    }
    
    private func createLogFiles() {
        FileSystemManager.createLogFiles()
    }
    
    private func resetLastPingTimestamp() {
        UserDefaults.shared.set(0, forKey: "LastPingTimestamp")
    }
    
    private func clearURLCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    private func refreshUI() {
        if let mainViewController = UIApplication.topViewController() as? MainViewController {
            mainViewController.refreshUI()
        }
    }
    
    private func showSecurityScreen() {
        var showWindow = false
        
        if UIApplication.topViewController() as? AccountViewController != nil {
            showWindow = true
        }
        
        if UIApplication.topViewController() as? LoginViewController != nil {
            showWindow = true
        }
        
        if UIApplication.topViewController() as? CreateAccountViewController != nil {
            showWindow = true
        }
        
        if showWindow {
            securityWindow.isHidden = false
            UIView.animate(withDuration: 0.15, animations: { [self] in
                securityWindow.rootViewController?.view.alpha = 1
            })
        }
    }
    
    private func hideSecurityScreen() {
        UIView.animate(withDuration: 0.15, animations: { [self] in
            securityWindow.rootViewController?.view.alpha = 0
        }, completion: { [self] _ in
            securityWindow.isHidden = true
        })
    }
    
    private func handleURLEndpoint(_ endpoint: String) {
        guard let viewController = UIApplication.topViewController() else {
            return
        }
        
        switch endpoint {
        case Config.urlTypeConnect:
            guard !UserDefaults.shared.disableWidgetPrompt else {
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                    return
                }
                Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
                return
            }
            
            viewController.showActionAlert(title: "Please confirm", message: "Do you want to connect to VPN?", action: "Connect", actionHandler: { _ in
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                    return
                }
                Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
            })
        case Config.urlTypeDisconnect:
            guard !UserDefaults.shared.disableWidgetPrompt else {
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                    return
                }
                Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
                return
            }
            
            viewController.showActionAlert(title: "Please confirm", message: "Do you want to disconnect from VPN?", action: "Disconnect", actionHandler: { _ in
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                    return
                }
                Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
            })
        case Config.urlTypeLogin:
            if UIApplication.topViewController() as? LoginViewController != nil {
                return
            }
            
            if let topViewController = UIApplication.topViewController() {
                topViewController.present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    private func startPurchaseObserver() {
        PurchaseManager.shared.delegate = self
        PurchaseManager.shared.startObserver()
    }

}

// MARK: - UIApplicationDelegate -

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        evaluateUITests()
        registerUserDefaults()
        createLogFiles()
        resetLastPingTimestamp()
        clearURLCache()
        startPurchaseObserver()
        DNSManager.shared.loadProfile { _ in }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let mainViewController = UIApplication.topViewController() as? MainViewController {
            if let controlPanelViewController = mainViewController.floatingPanel.contentViewController as? ControlPanelViewController {
                controlPanelViewController.refreshServiceStatus()
            }
            
            mainViewController.refreshUI()
        }
        
        if UserDefaults.shared.networkProtectionEnabled {
            NetworkManager.shared.startMonitoring()
        }
        
        hideSecurityScreen()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        hideSecurityScreen()
        refreshUI()
        NetworkManager.shared.stopMonitoring()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        showSecurityScreen()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        showSecurityScreen()
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard Application.shared.authentication.isLoggedIn, Application.shared.serviceStatus.isActive else {
            return
        }
        
        switch shortcutItem.type {
        case "Connect":
            DispatchQueue.delay(0.75) {
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                    return
                }
                Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
            }
            
            completionHandler(true)
        case "Disconnect":
            DispatchQueue.delay(0.75) {
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                    return
                }
                Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
            }
            
            completionHandler(true)
        default:
            completionHandler(false)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let endpoint = url.lastPathComponent
        handleURLEndpoint(endpoint)
        return true
    }
    
}

// MARK: - PurchaseManagerDelegate -

extension AppDelegate: PurchaseManagerDelegate {
    
    func purchaseStart() {
        
    }
    
    func purchasePending() {
        DispatchQueue.main.async {
            guard let viewController = UIApplication.topViewController() else {
                return
            }

            viewController.showAlert(title: "Pending payment", message: "Payment is pending for approval. We will complete the transaction as soon as payment is approved.")
        }
    }
    
    func purchaseSuccess(activeUntil: String, extended: Bool) {
        guard extended else {
            return
        }
        
        DispatchQueue.main.async {
            guard let viewController = UIApplication.topViewController() else {
                return
            }

            viewController.showSubscriptionActivatedAlert(activeUntil: activeUntil)
        }
    }
    
    func purchaseError(error: Any?) {
        DispatchQueue.main.async {
            guard let viewController = UIApplication.topViewController() else {
                return
            }
            
            if let error = error as? ErrorResult {
                viewController.showErrorAlert(title: "Error", message: error.message)
            }
        }
    }
    
}
