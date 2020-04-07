//
//  ControlPanelView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 07/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class ControlPanelView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var protectionStatusLabel: UILabel!
    @IBOutlet weak var connectSwitch: UISwitch!
    @IBOutlet weak var enableMultiHopButton: UIButton!
    @IBOutlet weak var disableMultiHopButton: UIButton!
    @IBOutlet weak var exitServerConnectionLabel: UILabel!
    @IBOutlet weak var exitServerNameLabel: UILabel!
    @IBOutlet weak var exitServerFlagImage: UIImageView!
    @IBOutlet weak var entryServerConnectionLabel: UILabel!
    @IBOutlet weak var entryServerNameLabel: UILabel!
    @IBOutlet weak var entryServerFlagImage: UIImageView!
    @IBOutlet weak var fastestServerLabel: UILabel!
    @IBOutlet weak var antiTrackerSwitch: UISwitch!
    @IBOutlet weak var networkView: NetworkViewTableCell!
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        
    }
    
    // MARK: - Methods -
    
    func setupView() {
        
    }
    
    func updateConnectionInfo(viewModel: ProofsViewModel) {
        ipAddressLabel.text = viewModel.ipAddress
        locationLabel.text = "\(viewModel.city), \(viewModel.countryCode)"
        providerLabel.text = viewModel.provider
    }
    
}
