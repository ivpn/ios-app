//
//  PortTableViewCell.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-07-14.
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

class PortTableViewCell: UITableViewCell {
    
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var customLabel: UILabel!
    
    // MARK: - Methods -
    
    func setup(port: ConnectionSettings, selectedPort: ConnectionSettings, ports: [ConnectionSettings]) {
        protocolLabel.text = port.formatProtocol()
        customLabel.isHidden = !isCustom(port: port, ports: ports)
        accessoryType = port == selectedPort ? .checkmark : .none
    }
    
    private func isCustom(port: ConnectionSettings, ports: [ConnectionSettings]) -> Bool {
        for portObj in ports where portObj.port() == port.port() {
            return false
        }
        
        return true
    }

}
