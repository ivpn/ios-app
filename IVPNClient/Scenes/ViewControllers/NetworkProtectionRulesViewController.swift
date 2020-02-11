//
//  NetworkProtectionRulesViewController.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 26/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

class NetworkProtectionRulesViewController: UITableViewController {
    
    @IBOutlet weak var untrustedConnectSwitch: UISwitch!
    @IBOutlet weak var trustedDisconnectSwitch: UISwitch!
    let defaults = UserDefaults.shared
    
    @IBAction func toggleUntrustedConnect(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.networkProtectionUntrustedConnect)
        Application.shared.connectionManager.evaluateConnection()
    }
    
    @IBAction func toggleTrustedDisconnect(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: UserDefaults.Key.networkProtectionTrustedDisconnect)
        Application.shared.connectionManager.evaluateConnection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        untrustedConnectSwitch.setOn(defaults.networkProtectionUntrustedConnect, animated: false)
        trustedDisconnectSwitch.setOn(defaults.networkProtectionTrustedDisconnect, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.Key.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = UIColor.init(named: Theme.Key.ivpnLabel6)
        }
    }
    
}
