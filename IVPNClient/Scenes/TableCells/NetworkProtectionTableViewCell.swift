//
//  NetworkProtectionTableViewCell.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 21/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

class NetworkProtectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var trustLabel: UILabel!
    @IBOutlet weak var defaultTrustLabel: UILabel!
    @IBOutlet weak var trustLabelTopConstraint: NSLayoutConstraint!
    
    // MARK: - Methods -
    
    func render(network: Network, defaultNetwork: Network?) {
        nameLabel.text = network.name
        trustLabel.text = network.trust?.uppercased()
        
        if let defaultNetwork = defaultNetwork {
            defaultTrustLabel.text = defaultNetwork.trust
        } else {
            defaultTrustLabel.text = NetworkTrust.None.rawValue
        }
        
        switch network.trust {
        case NetworkTrust.Untrusted.rawValue:
            trustLabel.textColor = UIColor.init(named: Theme.ivpnRed)
            setTrustLayout(withDefault: false)
        case NetworkTrust.Trusted.rawValue:
            trustLabel.textColor = UIColor.init(named: Theme.ivpnGreen)
            setTrustLayout(withDefault: false)
        default:
            trustLabel.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
            setTrustLayout(withDefault: true)
        }
        
        if network.isDefault {
            setTrustLayout(withDefault: false)
        }
    }
    
    private func setTrustLayout(withDefault: Bool) {
        defaultTrustLabel.isHidden = !withDefault
        
        if withDefault {
            trustLabelTopConstraint.constant = 8
        } else {
            trustLabelTopConstraint.constant = 17
        }
    }
    
}
