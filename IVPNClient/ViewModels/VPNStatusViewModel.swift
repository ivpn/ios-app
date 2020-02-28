//
//  VPNStatusViewModel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 28/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import NetworkExtension

struct VPNStatusViewModel {
    
    // MARK: - Properties -
    
    var model: NEVPNStatus
    
    var protectionStatusText: String {
        switch model {
        case .connecting, .reasserting:
            return "connecting"
        case .disconnecting:
            return "disconnecting"
        case .connected:
            return "protected"
        default:
            return "unprotected"
        }
    }
    
    var connectToServerText: String {
        switch model {
        case .connected:
            return "Connected to"
        default:
            return "Connect to"
        }
    }
    
    var connectToggleIsOn: Bool {
        switch model {
        case .connected, .connecting, .reasserting:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Initialize -
    
    init(model: NEVPNStatus) {
        self.model = model
    }
    
}
