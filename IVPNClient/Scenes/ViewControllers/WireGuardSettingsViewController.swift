//
//  WireGuardSettingsViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-29.
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
import JGProgressHUD
import NetworkExtension

class WireGuardSettingsViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var keyTimestampLabel: UILabel!
    @IBOutlet weak var keyExpirationTimestampLabel: UILabel!
    @IBOutlet weak var keyRegenerationTimestampLabel: UILabel!
    @IBOutlet weak var mtuLabel: UILabel!
    @IBOutlet weak var qrLabel: UILabel!
    
    // MARK: - Properties -
    
    let keyManager = AppKeyManager()
    let hud = JGProgressHUD(style: .dark)
    
    // MARK: - @IBActions -
    
    @IBAction func copyPublicKey(_ sender: UIButton) {
        guard let text = publicKeyLabel.text else { return }
        UIPasteboard.general.string = text
        showFlashNotification(message: "Public key copied to clipboard", presentInView: (navigationController?.view)!)
    }
    
    @IBAction func copyIpAddress(_ sender: UIButton) {
        guard let text = ipAddressLabel.text else { return }
        UIPasteboard.general.string = text
        showFlashNotification(message: "IP address copied to clipboard", presentInView: (navigationController?.view)!)
    }
    
    @IBAction func regenerateKeys(_ sender: UIButton) {
        guard evaluateIsNetworkReachable() else {
            return
        }
        
        Application.shared.connectionManager.isOnDemandEnabled { [self] enabled in
            if enabled, Application.shared.connectionManager.status.isDisconnected() {
                showDisableVPNPrompt(sourceView: sender) {
                    Application.shared.connectionManager.removeOnDemandRules { [self] in
                        keyManager.setNewKey { _, _, _ in }
                    }
                }
                return
            }
            
            guard Application.shared.connectionManager.status.isDisconnected() else {
                showConnectedAlert(message: "To re-generate keys, please first disconnect", sender: sender)
                return
            }
            
            keyManager.setNewKey { _, _, _ in }
        }
    }
    
    @IBAction func configureMtu(_ sender: Any) {
        let viewController = NavigationManager.getMTUViewController(delegate: self)
        present(viewController, animated: true)
    }
    
    @IBAction func quantumInfo(_ sender: UIButton) {
        showAlert(title: "Info", message: "Quantum Resistance: Indicates whether your current WireGuard VPN connection is using additional protection measures against potential future quantum computer attacks.\n\nWhen Enabled, a Pre-shared key has been securely exchanged between your device and the server using post-quantum Key Encapsulation Mechanism (KEM) algorithms. If Disabled, the current VPN connection, while secure under today's standards, does not include this extra layer of quantum resistance.")
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyManager.delegate = self
        setupView()
        addObservers()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        ipAddressLabel.text = KeyChain.wgIpAddress
        publicKeyLabel.text = KeyChain.wgPublicKey
        keyTimestampLabel.text = AppKeyManager.keyTimestamp.formatDate()
        keyExpirationTimestampLabel.text = AppKeyManager.keyExpirationTimestamp.formatDate()
        keyRegenerationTimestampLabel.text = AppKeyManager.keyRegenerationTimestamp.formatDate()
        let mtu = UserDefaults.standard.wgMtu
        mtuLabel.text = mtu > 0 ? String(mtu) : "Leave blank to use default value"
        qrLabel.text = KeyChain.wgPresharedKey == nil ? "Disabled" : "Enabled"
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateVpnStatus(_:)), name: Notification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    private func showConnectedAlert(message: String, sender: Any?, completion: (() -> Void)? = nil) {
        if let sourceView = sender as? UIView {
            showActionSheet(title: message, actions: ["Disconnect"], sourceView: sourceView) { index in
                if let completion = completion {
                    completion()
                }
                
                switch index {
                case 0:
                    let status = Application.shared.connectionManager.status
                    guard Application.shared.connectionManager.canDisconnect(status: status) else {
                        self.showAlert(title: "Cannot disconnect", message: "IVPN cannot disconnect from the current network while it is marked \"Untrusted\"")
                        return
                    }
                    self.disconnect()
                default:
                    break
                }
            }
        }
    }
    
    @objc private func onUpdateVpnStatus(_ notification: NSNotification) {
        guard let vpnConnection = notification.object as? NEVPNConnection else {
            return
        }
        
        if vpnConnection.status == .disconnected {
            hud.dismiss()
        }
    }
    
    private func disconnect() {
        NotificationCenter.default.post(name: Notification.Name.Disconnect, object: nil)
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Disconnecting"
        hud.show(in: (navigationController?.view)!)
        hud.dismiss(afterDelay: 5)
    }
    
}

// MARK: - UITableViewDelegate -

extension WireGuardSettingsViewController {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}

// MARK: - WGKeyManagerDelegate -

extension WireGuardSettingsViewController {
    
    override func setKeyStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Generating new keys..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func setKeySuccess() {
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.detailTextLabel.text = "WireGuard keys successfully regenerated and uploaded to IVPN server."
        hud.dismiss(afterDelay: 2)
        setupView()
    }
    
    override func setKeyFail() {
        hud.dismiss()
        showAlert(title: "Failed to regenerate WireGuard keys", message: "There was a problem regenerating and uploading WireGuard keys to IVPN server.")
        Application.shared.connectionManager.removeOnDemandRules {}
        setupView()
    }
    
}

// MARK: - MTUViewControllerDelegate -

extension WireGuardSettingsViewController: MTUViewControllerDelegate {
    
    func mtuSaved(isUpdated: Bool) {
        setupView()
        
        if isUpdated {
            evaluateReconnect(sender: mtuLabel)
        }
    }
    
}
