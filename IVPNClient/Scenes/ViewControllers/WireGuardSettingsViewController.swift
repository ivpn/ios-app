//
//  WireGuardSettingsViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-29.
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
import JGProgressHUD

class WireGuardSettingsViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var keyTimestampLabel: UILabel!
    @IBOutlet weak var keyExpirationTimestampLabel: UILabel!
    @IBOutlet weak var keyRegenerationTimestampLabel: UILabel!
    
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
        Application.shared.connectionManager.getStatus { _, status in
            if status == .connected || status == .connecting {
                self.showFlashNotification(message: "To re-generate keys, please first disconnect", presentInView: self.view)
                return
            }
            
            self.keyManager.setNewKey()
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        keyManager.delegate = self
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        ipAddressLabel.text = KeyChain.wgIpAddress
        publicKeyLabel.text = KeyChain.wgPublicKey
        keyTimestampLabel.text = AppKeyManager.keyTimestamp.formatDate()
        keyExpirationTimestampLabel.text = AppKeyManager.keyExpirationTimestamp.formatDate()
        keyRegenerationTimestampLabel.text = AppKeyManager.keyRegenerationTimestamp.formatDate()
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
    }
    
}
