//
//  ExperimentalViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19.08.2023..
//  Copyright © 2023 IVPN. All rights reserved.
//

import UIKit
import ActiveLabel

class ExperimentalViewController: UITableViewController {
    
    @IBOutlet weak var disableLanAccessSwitch: UISwitch!
    
    // MARK: - @IBActions -
    
    @IBAction func toggleDisableLanAccess(_ sender: UISwitch) {
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.disableLanAccess)
        evaluateReconnect(sender: sender as UIView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableLanAccessSwitch.setOn(UserDefaults.shared.disableLanAccess, animated: false)
    }

}

// MARK: - UITableViewDelegate -

extension ExperimentalViewController {
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        
        let urlString = "https://www.ivpn.net/knowledgebase/ios/known-issues-with-native-ios-kill-switch/"
        let label = ActiveLabel(frame: .zero)
        let customType = ActiveType.custom(pattern: "Learn more")
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.enabledTypes = [customType]
        label.text = footer.textLabel?.text
        label.textColor = UIColor.init(named: Theme.ivpnLabel6)
        label.customColor[customType] = UIColor.init(named: Theme.ivpnBlue)
        label.handleCustomTap(for: customType) { _ in
            self.openWebPage(urlString)
        }
        footer.addSubview(label)
        footer.textLabel?.text = ""
        label.bindFrameToSuperviewBounds(leading: 16, trailing: -16)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}
