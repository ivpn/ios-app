//
//  WireGuardSettingsViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 29/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
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
        keyManager.delegate = self
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        ipAddressLabel.text = KeyChain.wgIpAddress
        publicKeyLabel.text = KeyChain.wgPublicKey
        keyTimestampLabel.text = AppKeyManager.keyTimestamp.formatDateTime()
        keyExpirationTimestampLabel.text = AppKeyManager.keyExpirationTimestamp.formatDateTime()
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
