//
//  AppIntentsHandler.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 04.09.2024..
//  Copyright © 2024 IVPN. All rights reserved.
//

extension MainViewController {
    
    // MARK: - App Intents -
    
    @objc func intentConnect() {
        DispatchQueue.delay(0.75) {
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                return
            }
            Application.shared.connectionManager.connectShortcut(closeApp: true, actionType: .connect)
        }
    }
    
    @objc func intentDisconnect() {
        DispatchQueue.delay(0.75) {
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                return
            }
            Application.shared.connectionManager.disconnectShortcut(closeApp: true, actionType: .disconnect)
        }
    }
    
    @objc func intentAntiTrackerEnable() {
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
    
    @objc func intentAntiTrackerDisable() {
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
    
    @objc func intentCustomDNSEnable() {
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
    
    @objc func intentCustomDNSDisable() {
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
