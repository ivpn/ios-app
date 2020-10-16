//
//  NetworkViewTableCell.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-06.
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

class NetworkViewTableCell: UITableViewCell {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var trustLabel: UILabel!
    
    // MARK: - Properties -
    
    var defaultNetwork: Network? {
        if let defaultNetworks = StorageManager.fetchNetworks(isDefault: true) {
            if let first = defaultNetworks.first {
                return first
            }
        }
        return nil
    }
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateNetwork), name: Notification.Name.UpdateNetwork, object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.async {
            self.updateNetwork()
        }
    }
    
    // MARK: - Methods -
    
    func resetTrustToDefault() {
        if StorageManager.getDefaultTrust() == NetworkTrust.Trusted.rawValue {
            update(trust: NetworkTrust.Untrusted.rawValue)
        } else {
            update(trust: NetworkTrust.Default.rawValue)
        }
    }
    
    func update(trust: String) {
        Application.shared.network.trust = trust
        let network = Application.shared.network
        
        if let networks = StorageManager.fetchNetworks(name: network.name ?? "", type: network.type ?? "") {
            if let first = networks.first {
                first.trust = trust
                StorageManager.saveContext()
            }
        }
        
        updateNetwork()
    }
    
    // MARK: - Private methods -
    
    @objc private func updateNetwork() {
        render(network: Application.shared.network, defaultNetwork: defaultNetwork)
    }
    
    private func render(network: Network, defaultNetwork: Network?) {
        trustLabel.isHidden = false
        trustLabel.text = network.trust?.uppercased()
        accessoryType = .disclosureIndicator
        selectionStyle = .default
        
        switch network.trust {
        case NetworkTrust.Untrusted.rawValue:
            trustLabel.backgroundColor = UIColor.init(named: Theme.ivpnRedOff)
        case NetworkTrust.Trusted.rawValue:
            trustLabel.backgroundColor = UIColor.init(named: Theme.ivpnGreen)
        default:
            trustLabel.backgroundColor = UIColor.init(named: Theme.ivpnLabel5)
        }
        
        switch network.type {
        case NetworkType.wifi.rawValue:
            nameLabel.icon(text: network.name!, imageName: "WiFi")
        case NetworkType.cellular.rawValue:
            nameLabel.icon(text: network.name!, imageName: "Cellular")
        case NetworkType.none.rawValue:
            if network.name == "Wi-Fi" {
                nameLabel.icon(text: network.name!, imageName: "WiFi")
            } else {
                nameLabel.text = network.name
            }
            accessoryType = .none
            selectionStyle = .none
            trustLabel.isHidden = true
        default:
            break
        }
    }
    
}
