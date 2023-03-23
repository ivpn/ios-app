//
//  ProtocolTableViewCell.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda
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

class ProtocolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var protocolSettingsLabel: UILabel!
    
    private var protocolLabelText: String {
        let tunnelType = Application.shared.settings.connectionProtocol.tunnelType()
        
        if !UIDevice.screenHeightLargerThan(device: .iPhones55s5cSE) {
            if tunnelType == .wireguard {
                return "Port"
            }
            
            return "Protocol & port"
        }
        
        if tunnelType == .wireguard {
            return "Preferred port"
        }
        
        return "Preferred protocol & port"
    }
    
    private var multiHopProtocolLabelText: String {
        if !UIDevice.screenHeightLargerThan(device: .iPhones55s5cSE) {
            return "Protocol"
        }
        
        return "Preferred protocol"
    }
    
    // MARK: - Methods -
    
    func setup(connectionProtocol: ConnectionSettings, isSettings: Bool) {
        var title = connectionProtocol.formatTitle()
        var isChecked = connectionProtocol.tunnelType() == Application.shared.settings.connectionProtocol.tunnelType()
        
        if isSettings {
            title = connectionProtocol.formatProtocol()
            isChecked = connectionProtocol == Application.shared.settings.connectionProtocol
        }
        
        if connectionProtocol == .openvpn(.udp, 0) && UserDefaults.shared.isMultiHop {
            setupSelectAction(title: multiHopProtocolLabelText)
        } else if connectionProtocol == .openvpn(.udp, 0) || connectionProtocol == .wireguard(.udp, 0) {
            setupSelectAction(title: protocolLabelText)
        } else if connectionProtocol == .wireguard(.udp, 2) {
            setupAction(title: "WireGuard details")
        } else {
            updateLabel(title: title, isChecked: isChecked)
        }
        
        tintColor = UIColor.init(named: Theme.ivpnBlue)
    }
    
    private func updateLabel(title: String, isChecked: Bool) {
        protocolLabel.text = title
        protocolSettingsLabel.text = ""
        isUserInteractionEnabled = !isChecked
        
        if isChecked {
            accessoryType = .checkmark
            selectionStyle = .none
        } else {
            accessoryType = .none
            selectionStyle = .default
        }
    }
    
    private func setupSelectAction(title: String) {
        protocolLabel.text = title
        protocolSettingsLabel.text = UserDefaults.shared.isMultiHop ? Application.shared.settings.connectionProtocol.protocolType() : Application.shared.settings.connectionProtocol.formatProtocol()
        accessoryType = .disclosureIndicator
        isUserInteractionEnabled = true
        selectionStyle = .default
    }
    
    private func setupAction(title: String) {
        protocolLabel.text = title
        protocolSettingsLabel.text = ""
        accessoryType = .disclosureIndicator
    }
    
}
