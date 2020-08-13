//
//  VPNStatusViewModel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-02-28.
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
            return "connected"
        default:
            return "disconnected"
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
    
    var popupStatusText: String {
        switch status {
        case .connecting, .reasserting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        case .connected:
            return "Connected to"
        default:
            return "Your current location"
        }
    }
    
    // MARK: - Initialize -
    
    init(status: NEVPNStatus) {
        self.status = status
    }
    
}
