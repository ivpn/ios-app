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
    
    private func finishIncompletePurchases() {
        guard Application.shared.authentication.isLoggedIn || KeyChain.tempUsername != nil else {
            return
        }
        
        IAPManager.shared.finishIncompletePurchases { serviceStatus, _ in
            guard let viewController = UIApplication.topViewController() else { return }

            if let serviceStatus = serviceStatus {
                viewController.showSubscriptionActivatedAlert(serviceStatus: serviceStatus)
            }
        }
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
    
    private func userActivityConnect() {
        DispatchQueue.delay(0.75) {
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                return
            }
            Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
        }
    }
    
    private func userActivityDisconnect() {
        DispatchQueue.delay(0.75) {
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                return
            }
            Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
        }
    }
    
    private func userActivityAntiTrackerEnable() {
        DispatchQueue.async {
            if let viewController = UIApplication.topViewController() {
                if Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
                    viewController.showAlert(title: "IKEv2 not supported", message: "AntiTracker is supported only for OpenVPN and WireGuard protocols.") { _ in
                    }
                    return
                }
                
                UserDefaults.shared.set(true, forKey: UserDefaults.Key.isAntiTracker)
                NotificationCenter.default.post(name: Notification.Name.AntiTrackerUpdated, object: nil)
                if UIApplication.topViewController() as? MainViewController != nil {
                    NotificationCenter.default.post(name: Notification.Name.EvaluateReconnect, object: nil)
                } else {
                    viewController.evaluateReconnect(sender: viewController.view)
                }
            }
        }
    }
    
    private func userActivityAntiTrackerDisable() {
        DispatchQueue.async {
            if let viewController = UIApplication.topViewController() {
                UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
                NotificationCenter.default.post(name: Notification.Name.AntiTrackerUpdated, object: nil)
                if UIApplication.topViewController() as? MainViewController != nil {
                    NotificationCenter.default.post(name: Notification.Name.EvaluateReconnect, object: nil)
                } else {
                    viewController.evaluateReconnect(sender: viewController.view)
                }
            }
        }
    }
    
    private func userActivityCustomDNSEnable() {
        DispatchQueue.async {
            if let viewController = UIApplication.topViewController() {
                if Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
                    viewController.showAlert(title: "IKEv2 not supported", message: "Custom DNS is supported only for OpenVPN and WireGuard protocols.") { _ in
                    }
                    return
                }
                
                guard !UserDefaults.shared.customDNS.isEmpty else {
                    viewController.showAlert(title: "", message: "Please enter DNS server info")
                    return
                }
                
                UserDefaults.shared.set(true, forKey: UserDefaults.Key.isCustomDNS)
                NotificationCenter.default.post(name: Notification.Name.CustomDNSUpdated, object: nil)
                if UIApplication.topViewController() as? MainViewController != nil {
                    NotificationCenter.default.post(name: Notification.Name.EvaluateReconnect, object: nil)
                } else {
                    viewController.evaluateReconnect(sender: viewController.view)
                }
            }
        }
    }
    
    private func userActivityCustomDNSDisable() {
        DispatchQueue.async {
            if let viewController = UIApplication.topViewController() {
                UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
                NotificationCenter.default.post(name: Notification.Name.CustomDNSUpdated, object: nil)
                if UIApplication.topViewController() as? MainViewController != nil {
                    NotificationCenter.default.post(name: Notification.Name.EvaluateReconnect, object: nil)
                } else {
                    viewController.evaluateReconnect(sender: viewController.view)
                }
            }
        }
    }

}

// MARK: - UIApplicationDelegate -

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        evaluateUITests()
        registerUserDefaults()
        finishIncompletePurchases()
        createLogFiles()
        resetLastPingTimestamp()
        clearURLCache()
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            let endpoint = url.lastPathComponent
            handleURLEndpoint(endpoint)
            return false
        }
        
        guard Application.shared.authentication.isLoggedIn, Application.shared.serviceStatus.isActive else {
            return false
        }
        
        switch userActivity.activityType {
        case UserActivityType.Connect:
            userActivityConnect()
        case UserActivityType.Disconnect:
            userActivityDisconnect()
        case UserActivityType.AntiTrackerEnable:
            userActivityAntiTrackerEnable()
        case UserActivityType.AntiTrackerDisable:
            userActivityAntiTrackerDisable()
        case UserActivityType.CustomDNSEnable:
            userActivityCustomDNSEnable()
        case UserActivityType.CustomDNSDisable:
            userActivityCustomDNSDisable()
        default:
            log(.info, message: "No such user activity")
        }
        
        return false
    }
    
}
