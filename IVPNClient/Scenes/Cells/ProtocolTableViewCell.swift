//
//  ProtocolTableViewCell.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda
//  Copyright © 2017 IVPN. All rights reserved.
//

import UIKit

class ProtocolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var protocolSettingsLabel: UILabel!
    
    private var protocolLabelText: String {
        if !UIDevice.screenHeightLargerThan(device: .iPhones55s5cSE) { return "Protocol & port" }
        return "Preferred protocol & port"
    }
    
    // MARK: - Methods -
    
    func setup(connectionProtocol: ConnectionSettings, isSettings: Bool) {
        var title = connectionProtocol.formatTitle()
        var isChecked = connectionProtocol.tunnelType() == Application.shared.settings.connectionProtocol.tunnelType()
        
        if isSettings {
            title = connectionProtocol.formatProtocol()
            isChecked = connectionProtocol == Application.shared.settings.connectionProtocol
        }
        
        if connectionProtocol == .openvpn(.udp, 0) || connectionProtocol == .wireguard(.udp, 0) {
            setupSelectAction(title: protocolLabelText)
        } else if connectionProtocol == .wireguard(.udp, 2) {
            setupAction(title: "WireGuard details")
        } else {
            updateLabel(title: title, isChecked: isChecked)
        }
        
        tintColor = UIColor.init(named: Theme.Key.ivpnBlue)
    }
    
    private func updateLabel(title: String, isChecked: Bool) {
        protocolLabel.text = title
        protocolSettingsLabel.text = ""
        
        if isChecked {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
    
    private func setupSelectAction(title: String) {
        protocolLabel.text = title
        protocolSettingsLabel.text = Application.shared.settings.connectionProtocol.formatProtocol()
        accessoryType = .disclosureIndicator
    }
    
    private func setupAction(title: String) {
        protocolLabel.text = title
        protocolSettingsLabel.text = ""
        accessoryType = .disclosureIndicator
    }
    
}
