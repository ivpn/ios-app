//
//  ExperimentalViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19.08.2023..
//  Copyright © 2023 IVPN. All rights reserved.
//

import UIKit

class ExperimentalViewController: UITableViewController {
    
    @IBOutlet weak var disableLanAccessSwitch: UISwitch!
    
    // MARK: - @IBActions -
    
    @IBAction func toggleDisableLanAccess(_ sender: UISwitch) {
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.disableLanAccess)
        disableLanAccessSwitch.isEnabled = sender.isOn
        evaluateReconnect(sender: sender as UIView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableLanAccessSwitch.setOn(UserDefaults.shared.disableLanAccess, animated: false)
    }

}

// MARK: - UITableViewDelegate -

extension ExperimentalViewController {
    
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
