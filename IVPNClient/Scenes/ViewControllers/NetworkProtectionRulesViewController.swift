//
//  NetworkProtectionRulesViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-11-26.
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

class NetworkProtectionRulesViewController: UITableViewController {
    
    @IBOutlet weak var untrustedConnectSwitch: UISwitch!
    @IBOutlet weak var untrustedBlockLanSwitch: UISwitch!
    @IBOutlet weak var trustedDisconnectSwitch: UISwitch!
    let defaults = UserDefaults.shared
    
    @IBAction func toggleUntrustedConnect(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.networkProtectionUntrustedConnect)
        Application.shared.connectionManager.evaluateConnection { [self] error in
            if error != nil {
                showWireGuardKeysMissingError()
            }
        }
    }
    
    @IBAction func toggleUntrustedBlockLan(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "Block LAN traffic is supported only for OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        defaults.set(sender.isOn, forKey: UserDefaults.Key.networkProtectionUntrustedBlockLan)
        evaluateReconnect(sender: sender as UIView)
    }
    
    @IBAction func blockLanInfo(_ sender: UIButton) {
        showAlert(title: "Info", message: "When enabled, it overrides the 'Block LAN traffic' option in Advanced Settings.")
    }
    
    @IBAction func toggleTrustedDisconnect(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.networkProtectionTrustedDisconnect)
        Application.shared.connectionManager.evaluateConnection { [self] error in
            if error != nil {
                showWireGuardKeysMissingError()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        untrustedConnectSwitch.setOn(defaults.networkProtectionUntrustedConnect, animated: false)
        untrustedBlockLanSwitch.setOn(defaults.networkProtectionUntrustedBlockLan, animated: false)
        trustedDisconnectSwitch.setOn(defaults.networkProtectionTrustedDisconnect, animated: false)
    }
    
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
