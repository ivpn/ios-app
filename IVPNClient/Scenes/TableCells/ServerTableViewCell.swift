//
//  ServerTableViewCell.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-16.
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

class ServerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flagImage: FlagImageView!
    @IBOutlet weak var serverLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var pingImage: UIImageView!
    @IBOutlet weak var pingTimeMs: UILabel!
    @IBOutlet weak var configureButton: UIButton!
    @IBOutlet weak var ipv6Label: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    var viewModel: VPNServerViewModel! {
        didSet {
            if !isMultiHop && indexPath.row == 0 {
                setFastestServerCell()
            } else if isMultiHop && indexPath.row == 0 || !isMultiHop && indexPath.row == 1 {
                setRandomServerCell()
            } else if viewModel.server.isHost {
                setHostServerCell()
            } else {
                setGatewayServerCell()
            }
            
            setCellAppearance()
            setPingTime()
        }
    }
    
    var serverToValidate: VPNServer! {
        didSet {
            if !Application.shared.serverList.validateServer(firstServer: viewModel.server, secondServer: serverToValidate) {
                serverName.textColor = UIColor.init(named: Theme.ivpnLabel6)
                flagImage.alpha = 0.5
            } else {
                serverName.textColor = UIColor.init(named: Theme.ivpnLabelPrimary)
                flagImage.alpha = 1
            }
        }
    }
    
    var indexPath: IndexPath! {
        didSet {
            if indexPath.row == 0 || !isMultiHop && indexPath.row == 1 {
                pingImage.isHidden = true
                pingTimeMs.isHidden = true
            }
        }
    }
    
    var expandedGateways: [String]! {
        didSet {
            if expandedGateways.contains(viewModel.server.gateway) {
                expandButton.setImage(UIImage(named: "icon-arrow-up-gray"), for: .normal)
            } else {
                expandButton.setImage(UIImage(named: "icon-arrow-down-gray"), for: .normal)
            }
        }
    }
    
    var isMultiHop: Bool!
    
    // MARK: - Methods -
    
    private func setCellAppearance() {
        flagImage.updateUpFlagIcon()
        serverName.sizeToFit()
        ipv6Label.isHidden = !viewModel.showIPv6Label
        expandButton.tintColor = UIColor.init(named: Theme.ivpnGray6)
    }
    
    private func setFastestServerCell() {
        flagImage.image = UIImage(named: "icon-fastest-server")
        flagImage.image?.accessibilityIdentifier = "icon-fastest-server"
        serverName.text = "Fastest server"
        configureButton.isHidden = false
        configureButton.isUserInteractionEnabled = true
        expandButton.isHidden = true
    }
    
    private func setRandomServerCell() {
        flagImage.image = UIImage(named: "icon-shuffle")
        flagImage.image?.accessibilityIdentifier = "icon-shuffle"
        serverName.text = "Random server"
        configureButton.isHidden = true
        configureButton.isUserInteractionEnabled = true
        expandButton.isHidden = true
    }
    
    private func setGatewayServerCell() {
        let sort = ServersSort.init(rawValue: UserDefaults.shared.serversSort) ?? .city
        flagImage.image = viewModel.imageForCountryCode
        flagImage.image?.accessibilityIdentifier = ""
        serverName.text = viewModel.formattedServerName(sort: sort)
        configureButton.isHidden = true
        configureButton.isUserInteractionEnabled = false
        expandButton.isHidden = !UserDefaults.shared.selectHost
    }
    
    private func setHostServerCell() {
        serverName.text = viewModel.formattedServerName
        configureButton.isHidden = true
        configureButton.isUserInteractionEnabled = false
        flagImage.image = nil
        flagImage.image?.accessibilityIdentifier = ""
        expandButton.isHidden = true
    }
    
    private func setPingTime() {
        if viewModel.server.isHost {
            pingImage.isHidden = true
            if let load = viewModel.server.load {
                pingTimeMs.text = "\(load)%"
                pingTimeMs.isHidden = false
            }
        } else if let pingMs = viewModel.server.pingMs {
            if pingMs == -1 {
                pingTimeMs.text = "Offline"
            } else {
                pingTimeMs.text = "\(pingMs)ms"
            }
            pingImage.image = viewModel.imageForPingTime
            pingImage.isHidden = false
            pingTimeMs.isHidden = false
            pingTimeMs.sizeToFit()
        } else {
            pingImage.isHidden = true
            pingTimeMs.isHidden = true
        }
    }
    
}
