//
//  NetworkView.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 27/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

protocol NetworkViewDelegate: class {
    func setNetworkTrust()
}

class NetworkView: UIView {
    
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var trustLabel: UILabel!
    @IBOutlet weak var defaultTrustLabel: UILabel!
    @IBOutlet weak var trustLabelTopConstraint: NSLayoutConstraint!
    
    weak var delegate: NetworkViewDelegate?
    
    var defaultNetwork: Network? {
        if let defaultNetworks = StorageManager.fetchNetworks(isDefault: true) {
            if let first = defaultNetworks.first {
                return first
            }
        }
        return nil
    }
    
    override func awakeFromNib() {
        updateNetwork()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNetwork), name: Notification.Name.UpdateNetwork, object: nil)
    }
    
    @objc func tapHandler() {
        if let networkType = Application.shared.network.type {
            if networkType == NetworkType.none.rawValue { return }
        } else {
            return
        }
        
        delegate?.setNetworkTrust()
    }
    
    @objc func updateNetwork() {
        render(network: Application.shared.network, defaultNetwork: defaultNetwork)
    }
    
    func render(network: Network, defaultNetwork: Network?) {
        detailButton.isHidden = false
        trustLabel.isHidden = false
        defaultTrustLabel.isHidden = true
        
        trustLabel.text = network.trust?.uppercased()
        
        if let defaultNetwork = defaultNetwork {
            defaultTrustLabel.text = defaultNetwork.trust
        } else {
            defaultTrustLabel.text = NetworkTrust.None.rawValue
        }
        
        switch network.trust {
        case NetworkTrust.Untrusted.rawValue:
            trustLabel.textColor = UIColor.init(named: Theme.Key.ivpnRed)
            setTrustLayout(withDefault: false)
        case NetworkTrust.Trusted.rawValue:
            trustLabel.textColor = UIColor.init(named: Theme.Key.ivpnGreen)
            setTrustLayout(withDefault: false)
        default:
            trustLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)
            setTrustLayout(withDefault: true)
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
            detailButton.isHidden = true
            trustLabel.isHidden = true
            defaultTrustLabel.isHidden = true
        default:
            defaultTrustLabel.isHidden = true
        }
        
        if network.isDefault {
            setTrustLayout(withDefault: false)
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
    
    func resetTrustToDefault() {
        if StorageManager.getDefaultTrust() == NetworkTrust.Trusted.rawValue {
            update(trust: NetworkTrust.Untrusted.rawValue)
        } else {
            update(trust: NetworkTrust.Default.rawValue)
        }
    }
    
    private func setTrustLayout(withDefault: Bool) {
        defaultTrustLabel.isHidden = !withDefault
        
        if withDefault {
            trustLabelTopConstraint.constant = 10
        } else {
            trustLabelTopConstraint.constant = 19
        }
    }
    
    override func layoutSubviews() {
        updateNetwork()
    }
    
}

// MARK: - NetworkTrustViewControllerDelegate -

extension NetworkView: NetworkTrustViewControllerDelegate {
    
    func selected(trust: String, indexPath: IndexPath) {
        update(trust: trust)
    }
    
}
