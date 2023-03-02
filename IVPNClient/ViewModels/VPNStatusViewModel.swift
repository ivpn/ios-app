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
            if PauseManager.shared.isPaused {
                return "paused"
            }
            
            return "disconnected"
        }
    }
    
    var connectToServerText: String {
        if UserDefaults.shared.isMultiHop {
            switch status {
            case .connected:
                return "Traffic is routed via entry server"
            default:
                return "Entry server is"
            }
        } else {
            switch status {
            case .connecting, .reasserting:
                return "Connecting to"
            case .connected:
                return "Traffic is routed via server"
            case .disconnecting:
            return "Disconnecting from"
            default:
                if Application.shared.settings.selectedServer.fastest || Application.shared.settings.selectedServer.fastestServerLabelShouldBePresented {
                    return "Fastest available server"
                }
                
                return "Selected server"
            }
        }
    }
    
    var connectToExitServerText: String {
        switch status {
        case .connected:
            return "Traffic is routed via exit server"
        default:
            return "Exit server is"
        }
    }
    
    var antiTrackerText: String {
        if UserDefaults.shared.isAntiTracker {
            switch status {
            case .connected:
                return "AntiTracker is enabled and actively blocking known trackers"
            default:
                return "AntiTracker will be enabled when connected to VPN"
            }
        }
        
        return "AntiTracker is disabled"
    }
    
    var connectToggleIsOn: Bool {
        switch status {
        case .connected, .connecting, .reasserting:
            return true
        default:
            return false
        }
    }
    
    var pauseIsHidden: Bool {
        if PauseManager.shared.isPaused {
            return false
        }
        
        switch status {
        case .connected:
            return false
        default:
            return true
        }
    }
    
    var pauseBackgroundColor: UIColor {
        if PauseManager.shared.isPaused {
            return UIColor.init(named: Theme.ivpnBlue)!
        }
        
        return UIColor.init(named: Theme.ivpnGray8)!
    }
    
    var pauseImage: String {
        if PauseManager.shared.isPaused {
            return "play"
        }
        
        return "pause"
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
            if PauseManager.shared.isPaused {
                return "Connection will resume automatically in"
            }
            
            return "Your current location"
        }
    }
    
    // MARK: - Initialize -
    
    init(status: NEVPNStatus) {
        self.status = status
    }
    
}
