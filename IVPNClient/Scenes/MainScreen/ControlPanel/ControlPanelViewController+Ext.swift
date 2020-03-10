//
//  ControlPanelViewController+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 02/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import Foundation
import JGProgressHUD

// MARK: - UITableViewDelegate -

extension ControlPanelViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 100 }
        if indexPath.row == 1 && Application.shared.settings.connectionProtocol.tunnelType() != .openvpn { return 0 }
        if indexPath.row == 1 { return 44 }
        if indexPath.row == 3 && !UserDefaults.shared.isMultiHop { return 0 }
        if indexPath.row == 4 { return 52 }
        if indexPath.row == 6 && !UserDefaults.shared.networkProtectionEnabled { return 0 }
        if indexPath.row == 8 { return 335 }

        return 85
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 2 {
            if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
                topViewController.performSegue(withIdentifier: "ControlPanelSelectServer", sender: nil)
            }
        }
        
        if indexPath.row == 3 {
            if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
                topViewController.performSegue(withIdentifier: "ControlPanelSelectExitServer", sender: nil)
            }
        }
        
        if indexPath.row == 6 && Application.shared.network.type != NetworkType.none.rawValue {
            if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
                topViewController.performSegue(withIdentifier: "MainScreenNetworkProtectionRules", sender: nil)
            }
        }
        
        if indexPath.row == 7 {
            if let topViewController = UIApplication.topViewController() as? MainViewControllerV2 {
                topViewController.performSegue(withIdentifier: "MainScreenSelectProtocol", sender: nil)
            }
        }
    }
    
}

// MARK: - WGKeyManagerDelegate -

extension ControlPanelViewController {
    
    override func setKeyStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Generating new keys..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func setKeySuccess() {
        hud.dismiss()
        connectionExecute()
    }
    
    override func setKeyFail() {
        hud.dismiss()
        
        if AppKeyManager.isKeyExpired {
            showAlert(title: "Failed to automatically regenerate WireGuard keys", message: "Cannot connect using WireGuard protocol: regenerating WireGuard keys failed. This is likely because of no access to an IVPN API server. You can retry connection, regenerate keys manually from preferences, or select another protocol. Please contact support if this error persists.")
        } else {
            showAlert(title: "Failed to regenerate WireGuard keys", message: "There was a problem generating and uploading WireGuard keys to IVPN server.")
        }
    }
    
}

// MARK: - ServerViewControllerDelegate -

extension ControlPanelViewController: ServerViewControllerDelegate {
    
    func reconnectToFastestServer() {
        Application.shared.connectionManager.getStatus { _, status in
            if status == .connected {
                self.needsToReconnect = true
                Application.shared.connectionManager.resetRulesAndDisconnect(reconnectAutomatically: true)
            }
        }
    }
    
}

// MARK: - SessionManagerDelegate -

extension ControlPanelViewController {
    
    override func createSessionSuccess() {
        connect(status: .disconnected)
    }
    
    override func createSessionServiceNotActive() {
        connect(status: .disconnected)
    }
    
    override func createSessionTooManySessions(error: Any?) {
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
        logOut(deleteSession: false)
        present(NavigationManager.getLoginViewController(), animated: true)
    }
    
    override func createSessionFailure(error: Any?) {
        if let error = error as? ErrorResultSessionNew {
            showErrorAlert(title: "Error", message: error.message)
        }
    }
    
    override func sessionStatusNotFound() {
        guard !UserDefaults.standard.bool(forKey: "-UITests") else { return }
        logOut(deleteSession: false)
        present(NavigationManager.getLoginViewController(), animated: true)
    }
    
    override func sessionStatusExpired() {
        showExpiredSubscriptionError()
    }
    
    override func deleteSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Deleting active session..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func deleteSessionSuccess() {
        hud.delegate = self as? JGProgressHUDDelegate
        hud.dismiss()
    }
    
    override func deleteSessionFailure() {
        hud.delegate = self as? JGProgressHUDDelegate
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.detailTextLabel.text = "There was an error deleting session"
        hud.show(in: (navigationController?.view)!)
        hud.dismiss(afterDelay: 2)
    }
    
    override func deleteSessionSkip() {
        present(NavigationManager.getLoginViewController(), animated: true)
    }
    
    func showCreateSessionAlert(message: String) {
        showActionSheet(title: message, actions: ["Log out from all other devices", "Try again"], sourceView: self.connectSwitch) { index in
            switch index {
            case 0:
                self.sessionManager.createSession(force: true)
            case 1:
                self.sessionManager.createSession()
            default:
                break
            }
        }
    }
    
}
