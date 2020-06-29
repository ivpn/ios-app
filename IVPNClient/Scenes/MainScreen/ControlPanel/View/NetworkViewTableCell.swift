//
//  NetworkViewTableCell.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 06/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
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
            if network.name == "WiFi" {
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
