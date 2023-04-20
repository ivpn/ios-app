//
//  DataService.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-17.
//  Copyright (c) 2023 Privatus Limited.
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

import NetworkExtension

protocol DataService {
    func getStatus() -> Status
    func getLocation() -> GeoLookup
    func getConnectionInfo() -> ConnectionInfo
}

class WidgetDataService: DataService {
    
    func getStatus() -> Status {
        let rawValue = UserDefaults.shared.connectionStatus
        let vpnStatus = NEVPNStatus.init(rawValue: rawValue) ?? .disconnected
        let isLoggedIn = UserDefaults.shared.isLoggedIn
        return Status(vpnStatus: vpnStatus, isLoggedIn: isLoggedIn)
    }
    
    func getLocation() -> GeoLookup {
        if let saved = UserDefaults.shared.object(forKey: UserDefaults.Key.geoLookup) as? Data {
            if let loaded = try? JSONDecoder().decode(GeoLookup.self, from: saved) {
                return loaded
            }
        }
        
        return GeoLookup(ipAddress: "", countryCode: "", country: "", city: "", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
    }
    
    func getConnectionInfo() -> ConnectionInfo {
        return ConnectionInfo(antiTracker: getAntiTracker(), selectedProtocol: getProtocol(), geoLookup: getLocation())
    }
    
    func getAntiTracker() -> Bool {
        return UserDefaults.shared.isAntiTracker
    }
    
    func getProtocol() -> String {
        return UserDefaults.shared.selectedProtocol
    }
    
}
