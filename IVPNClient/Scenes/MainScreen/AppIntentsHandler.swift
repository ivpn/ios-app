//
//  AppIntentsHandler.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 04.09.2024..
//  Copyright © 2024 IVPN. All rights reserved.
//

import UIKit

extension MainViewController {
    
    // MARK: - App Intents -
    
    @objc func intentConnect() {
        DispatchQueue.delay(0.75) {
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndConnectShortcut(closeApp: true, actionType: .connect)
                return
            }
            Application.shared.connectionManager.connect()
        }
    }
    
    @objc func intentDisconnect() {
        DispatchQueue.delay(0.75) {
            if UserDefaults.shared.networkProtectionEnabled {
                Application.shared.connectionManager.resetRulesAndDisconnectShortcut(closeApp: true, actionType: .disconnect)
                return
            }
            Application.shared.connectionManager.disconnect()
        }
    }
    
    @objc func intentAntiTrackerEnable() {
        DispatchQueue.async {
            if Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
                self.showAlert(title: "IKEv2 not supported", message: "AntiTracker is supported only for OpenVPN and WireGuard protocols.") { _ in
                }
                return
            }
            
            UserDefaults.shared.set(true, forKey: UserDefaults.Key.isAntiTracker)
            NotificationCenter.default.post(name: Notification.Name.AntiTrackerUpdated, object: nil)
            self.evaluateReconnect(sender: self.view)
        }
    }
    
    @objc func intentAntiTrackerDisable() {
        DispatchQueue.async {
            UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
            NotificationCenter.default.post(name: Notification.Name.AntiTrackerUpdated, object: nil)
            self.evaluateReconnect(sender: self.view)
        }
    }
    
    @objc func intentCustomDNSEnable() {
        DispatchQueue.async {
            if Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
                self.showAlert(title: "IKEv2 not supported", message: "Custom DNS is supported only for OpenVPN and WireGuard protocols.") { _ in
                }
                return
            }
            
            guard !UserDefaults.shared.customDNS.isEmpty else {
                self.showAlert(title: "", message: "Please enter DNS server info")
                return
            }
            
            UserDefaults.shared.set(true, forKey: UserDefaults.Key.isCustomDNS)
            NotificationCenter.default.post(name: Notification.Name.CustomDNSUpdated, object: nil)
            self.evaluateReconnect(sender: self.view)
        }
    }
    
    @objc func intentCustomDNSDisable() {
        DispatchQueue.async {
            UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
            NotificationCenter.default.post(name: Notification.Name.CustomDNSUpdated, object: nil)
            self.evaluateReconnect(sender: self.view)
        }
    }
    
}
