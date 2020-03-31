//
//  ServerConfigurationCell.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

protocol ServerConfigurationCellDelegate: class {
    func toggle(isOn: Bool, gateway: String)
    func showValidation(error: String)
}

class ServerConfigurationCell: UITableViewCell {
    
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var fastestEnabledSwitch: UISwitch!
    
    weak var delegate: ServerConfigurationCellDelegate?
    
    var isFastestEnabled: Bool {
        return fastestEnabledSwitch.isOn
    }
    
    @IBAction func toggle(_ sender: UISwitch) {
        guard StorageManager.canUpdateServer(isOn: sender.isOn) else {
            sender.setOn(true, animated: false)
            delegate?.showValidation(error: "At least one server should be chosen as the fastest server")
            return
        }
        
        delegate?.toggle(isOn: sender.isOn, gateway: viewModel.server.gateway)
    }
    
    var viewModel: VPNServerViewModel! {
        didSet {
            let fastestServerConfiguredKey = Application.shared.settings.fastestServerConfiguredKey
            
            flagImage.image = viewModel.imageForCountryCode
            serverLabel.text = viewModel.formattedServerName
            
            if UserDefaults.standard.bool(forKey: fastestServerConfiguredKey) {
                let isFastestEnabled = StorageManager.isFastestEnabled(server: viewModel.server)
                fastestEnabledSwitch.setOn(isFastestEnabled, animated: false)
            }
        }
    }
    
}
