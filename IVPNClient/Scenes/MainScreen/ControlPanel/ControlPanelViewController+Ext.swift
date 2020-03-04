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
        if indexPath.row == 8 && UserDefaults.shared.isMultiHop { return 335 }

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
