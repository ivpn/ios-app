//
//  Status.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-09.
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

import Foundation
import NetworkExtension

extension UserDefaults {
    
    static var shared: UserDefaults {
        return UserDefaults(suiteName: "group.net.ivpn.clients.ios")!
    }
    
    struct Key {
        static let connectionStatus = "connectionStatus"
    }

    @objc dynamic var connectionStatus: Int {
        return integer(forKey: Key.connectionStatus)
    }
    
}

class Status {
    
    var status: NEVPNStatus {
        let rawValue = UserDefaults.shared.connectionStatus
        return NEVPNStatus.init(rawValue: rawValue) ?? .invalid
    }
    
    var statusText: String {
        switch status {
        case .invalid:
            return "invalid"
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .reasserting:
            return "reasserting"
        case .disconnecting:
            return "disconnecting"
        @unknown default:
            return ""
        }
    }
    
    init() {
        
    }
    
}
