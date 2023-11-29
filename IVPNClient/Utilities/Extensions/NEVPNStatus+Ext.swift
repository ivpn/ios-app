//
//  NEVPNStatus+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-12-09.
//  Copyright (c) 2023 IVPN Limited.
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

import NetworkExtension

extension NEVPNStatus {
    
    func isDisconnected() -> Bool {
        // Fix for iOS 16+ bug where VPN status is .disconnecting for active on-demand rules and disconnected VPN
        if UserDefaults.shared.networkProtectionEnabled {
            return self == .disconnected || self == .disconnecting || self == .invalid
        }
        
        return self == .disconnected || self == .invalid
    }
    
}
