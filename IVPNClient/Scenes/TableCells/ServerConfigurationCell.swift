//
//  ServerConfigurationCell.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-02-19.
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

protocol ServerConfigurationCellDelegate: AnyObject {
    func toggle(isOn: Bool, server: VPNServer)
    func showValidation(error: String)
}

class ServerConfigurationCell: UITableViewCell {
    
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var fastestEnabledSwitch: UISwitch!
    
    weak var delegate: ServerConfigurationCellDelegate?
    
    @IBAction func toggle(_ sender: UISwitch) {
        guard StorageManager.canUpdateServer(isOn: sender.isOn) else {
            sender.setOn(true, animated: false)
            delegate?.showValidation(error: "At least one server should be chosen as the fastest server")
            return
        }
        
        delegate?.toggle(isOn: sender.isOn, server: viewModel.server)
    }
    
    var viewModel: VPNServerViewModel! {
        didSet {
            let sort = ServersSort.init(rawValue: UserDefaults.shared.serversSort) ?? .city
            
            flagImage.image = viewModel.imageForCountryCode
            serverLabel.text = viewModel.formattedServerName(sort: sort)
            
            if UserDefaults.standard.bool(forKey: UserDefaults.Key.fastestServerConfigured) {
                let isFastestEnabled = StorageManager.isFastestEnabled(server: viewModel.server)
                fastestEnabledSwitch.setOn(isFastestEnabled, animated: false)
            }
        }
    }
    
}
