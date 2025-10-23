//
//  ObfuscationViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2025-10-23.
//  Copyright (c) 2025 IVPN Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//


import UIKit
import ActiveLabel
import WidgetKit

class ObfuscationViewController: UITableViewController {
    
    // MARK: - @IBOutlets -

    @IBOutlet weak var v2raySwitch: UISwitch!
    @IBOutlet weak var v2rayProtocolControl: UISegmentedControl!
    
    // MARK: - Properties -
    
    var protocolType: String {
        return v2rayProtocolControl.selectedSegmentIndex == 1 ? "tcp" : "udp"
    }
    
    // MARK: - @IBActions -
    
    @IBAction func toggleV2ray(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() != .wireguard {
            showAlert(title: "OpenVPN and IKEv2 not supported", message: "V2Ray is supported only for WireGuard protocol.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        if !sender.isOn {
            Application.shared.settings.connectionProtocol = Config.defaultProtocol
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isV2ray)
        setupView()
        evaluateReconnect(sender: sender as UIView)
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
    }
    
    @IBAction func selectV2rayProtocol(_ sender: UISegmentedControl) {
        let v2rayProtocol = sender.selectedSegmentIndex == 1 ? "tcp" : "udp"
        UserDefaults.shared.set(v2rayProtocol, forKey: UserDefaults.Key.v2rayProtocol)
        
        if UserDefaults.shared.isV2ray {
            Application.shared.settings.connectionProtocol = Config.defaultProtocol
            evaluateReconnect(sender: sender as UIView)
            WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        v2raySwitch.setOn(UserDefaults.shared.isV2ray, animated: false)
        v2rayProtocolControl.selectedSegmentIndex = UserDefaults.shared.v2rayProtocol == "tcp" ? 1 : 0
        v2rayProtocolControl.isEnabled = UserDefaults.shared.isV2ray
    }

}

// MARK: - UITableViewDelegate -

extension ObfuscationViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        
        let urlString = "https://www.ivpn.net/knowledgebase/ios/v2ray/"
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
