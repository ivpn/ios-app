//
//  SecureDNSView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-02-15.
//  Copyright (c) 2021 Privatus Limited.
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

class SecureDNSView: UITableView {
    
    // MARK: - @IBOutlets -
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var serverField: UITextField!
    @IBOutlet weak var resolvedIPLabel: UILabel!
    @IBOutlet weak var serverURLLabel: UILabel!
    @IBOutlet weak var serverNameLabel: UILabel!
    @IBOutlet weak var typeControl: UISegmentedControl!
    @IBOutlet weak var mobileNetworkSwitch: UISwitch!
    @IBOutlet weak var wifiNetworkSwitch: UISwitch!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        addObservers()
    }
    
    // MARK: - Methods -
    
    func setupView(model: SecureDNS) {
        let type = DNSProtocolType.init(rawValue: model.type)
        serverField.text = model.address
        serverURLLabel.text = model.serverURL
        serverNameLabel.text = model.serverName
        typeControl.selectedSegmentIndex = type == .dot ? 1 : 0
        mobileNetworkSwitch.isOn = model.mobileNetwork
        wifiNetworkSwitch.isOn = model.wifiNetwork
        updateEnableSwitch()
        updateResolvedDNS()
    }
    
    @objc func updateEnableSwitch() {
        DNSManager.shared.loadProfile { _ in
            self.enableSwitch.isOn = DNSManager.shared.isEnabled
        }
    }
    
    @objc func updateResolvedDNS() {
        let resolvedDNS = UserDefaults.standard.value(forKey: UserDefaults.Key.resolvedDNSOutsideVPN) as? [String]
            ?? []
        resolvedIPLabel.text = resolvedDNS.map { String($0) }.joined(separator: ",")
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateEnableSwitch), name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateResolvedDNS), name: Notification.Name.UpdateResolvedDNS, object: nil)
    }
    
}
