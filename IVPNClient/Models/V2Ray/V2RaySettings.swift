//
//  V2RaySettings.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-09-18.
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
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

struct V2RaySettings: Codable {
    
    var id: String
    var outboundIp: String
    var outboundPort: Int
    var inboundIp: String
    var inboundPort: Int
    var dnsName: String
    var wireguard: [V2RayPort]
    
    var tlsSrvName: String {
        return dnsName.replacingOccurrences(of: "ivpn.net", with: "inet-telecom.com")
    }
    
    var singleHopInboundPort: Int {
        return wireguard.first?.port ?? 0
    }
    
    init(id: String = "", outboundIp: String = "", outboundPort: Int = 0, inboundIp: String = "", inboundPort: Int = 0, dnsName: String = "", wireguard: [V2RayPort] = []) {
        self.id = id
        self.outboundIp = outboundIp
        self.outboundPort = outboundPort
        self.inboundIp = inboundIp
        self.inboundPort = inboundPort
        self.dnsName = dnsName
        self.wireguard = wireguard
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.shared.set(encoded, forKey: UserDefaults.Key.v2raySettings)
        }
    }
    
    static func load() -> V2RaySettings? {
        if let saved = UserDefaults.shared.object(forKey: UserDefaults.Key.v2raySettings) as? Data {
            if let loaded = try? JSONDecoder().decode(V2RaySettings.self, from: saved) {
                return loaded
            }
        }
        
        return nil
    }
    
}

struct V2RayPort: Codable {
    let type: String
    let port: Int
}
