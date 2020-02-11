//
//  ServerTableViewCell.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/16/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var serverLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var pingImage: UIImageView!
    @IBOutlet weak var pingTimeMs: UILabel!
    @IBOutlet weak var configureButton: UIButton!
    
    var viewModel: VPNServerViewModel! {
        didSet {
            if !isMultiHop && indexPath.row == 0 {
                flagImage.image = UIImage(named: "icon-fastest-server")
                serverName.text = "Fastest server"
                configureButton.isHidden = false
                configureButton.isUserInteractionEnabled = true
            } else {
                flagImage.image = viewModel.imageForCountryCode
                serverName.text = viewModel.formattedServerName
                configureButton.isHidden = true
                configureButton.isUserInteractionEnabled = false
            }
            serverName.sizeToFit()
            
            if let pingMs = viewModel.server.pingMs {
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
    
    var serverToValidate: VPNServer! {
        didSet {
            if !Application.shared.serverList.validateServer(firstServer: viewModel.server, secondServer: serverToValidate) {
                serverName.textColor = UIColor.init(named: Theme.Key.ivpnLabel6)
                flagImage.alpha = 0.5
            } else {
                serverName.textColor = UIColor.init(named: Theme.Key.ivpnLabelPrimary)
                flagImage.alpha = 1
            }
        }
    }
    
    var selectedServer: VPNServer! {
        didSet {
            checkImage.isHidden = true
            
            if !isMultiHop && indexPath.row == 0 && selectedServer.fastest {
                checkImage.isHidden = false
            }
            
            if viewModel.server == selectedServer && !selectedServer.fastest {
                checkImage.isHidden = false
            }
        }
    }
    
    var indexPath: IndexPath! {
        didSet {
            if !isMultiHop && indexPath.row == 0 {
                pingImage.isHidden = true
                pingTimeMs.isHidden = true
            }
        }
    }
    
    var isMultiHop: Bool!
    
}
