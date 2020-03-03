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
    
    var status: NEVPNStatus
    
    var protectionStatusText: String {
        switch status {
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
        if UserDefaults.shared.isMultiHop {
            return "Entry Server"
        }
        
        switch status {
        case .connecting, .reasserting:
            return "Connecting to"
        case .connected:
            return "Connected to"
        case .disconnecting:
        return "Disconnecting from"
        default:
            return "Connect to"
        }
    }
    
    var connectToggleIsOn: Bool {
        switch status {
        case .connected, .connecting, .reasserting:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Initialize -
    
    init(status: NEVPNStatus) {
        self.status = status
    }
    
}
