//
//  AppDelegate.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-09-29.
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
import Sentry

@UIApplicationMain

class AppDelegate: UIResponder {
    
    // MARK: - Properties -
    
    var window: UIWindow?
    
    // MARK: - Methods -
    
    private func evaluateFirstRun() {
        if UserDefaults.standard.object(forKey: "FirstInstall") == nil {
            KeyChain.clearAll()
            UserDefaults.clearSession()
            UserDefaults.standard.set(false, forKey: "FirstInstall")
            UserDefaults.standard.synchronize()
        }
    }
    
    func setupCrashReports() {
        guard UserDefaults.shared.isLoggingCrashes else { return }
        
        do {
            Client.shared = try Client(dsn: "https://\(Config.SentryDsn)")
            Client.shared?.enabled = true
            Client.shared?.beforeSerializeEvent = { event in
                event.environment = Config.Environment
            }
            try Client.shared?.startCrashHandler()
            log(info: "Sentry crash handler started successfully")
        } catch let error {
            log(error: "\(error)")
        }
    }
    
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
        guard Application.shared.authentication.isLoggedIn || KeyChain.tempUsername != nil else { return }
        
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let endpoint = url.host else {
            return false
        }
        
        switch endpoint {
        case Config.urlTypeConnect:
            DispatchQueue.delay(0.75) {
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                    return
                }
                Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
            }
        case Config.urlTypeDisconnect:
            DispatchQueue.delay(0.75) {
                if UserDefaults.shared.networkProtectionEnabled {
                    Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                    return
                }
                Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
            }
        case Config.urlTypeLogin:
            if let topViewController = UIApplication.topViewController() {
                if #available(iOS 13.0, *) {
                    topViewController.present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
                } else {
                    topViewController.present(NavigationManager.getLoginViewController(), animated: true, completion: nil)
                }
            }
        default:
            break
        }
        
        return true
    }

}

// MARK: - UIApplicationDelegate -

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCrashReports()
        evaluateUITests()
        evaluateFirstRun()
        registerUserDefaults()
        finishIncompletePurchases()
        createLogFiles()
        resetLastPingTimestamp()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let mainViewController = UIApplication.topViewController() as? MainViewController {
            if let controlPanelViewController = mainViewController.floatingPanel.contentViewController as? ControlPanelViewController {
                controlPanelViewController.refreshServiceStatus()
            }
        }
        
        if UserDefaults.shared.networkProtectionEnabled {
            NetworkManager.shared.startMonitoring()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NetworkManager.shared.stopMonitoring()
        
        if let topViewController = UIApplication.topViewController() as? MainViewController {
            topViewController.refreshUI()
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard Application.shared.authentication.isLoggedIn, Application.shared.serviceStatus.isActive else { return }
        
        switch shortcutItem.type {
        case "Connect":
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                completionHandler(true)
                break
            }
            Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
            completionHandler(true)
        case "Disconnect":
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                completionHandler(true)
                break
            }
            Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
            completionHandler(true)
        default:
            completionHandler(false)
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard Application.shared.authentication.isLoggedIn, Application.shared.serviceStatus.isActive else { return false }
        
        switch userActivity.activityType {
        case UserActivityType.Connect:
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                break
            }
            Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
        case UserActivityType.Disconnect:
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                break
            }
            Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
        default:
            log(info: "No such user activity")
        }
        
        return false
    }
    
}
