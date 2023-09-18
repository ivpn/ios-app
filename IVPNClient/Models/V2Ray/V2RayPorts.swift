//
//  V2RayPorts.swift
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

struct V2RayPorts: Codable {
    
    let id: String
    var port: Int
    var host: V2RayHost
    let wireguard: [V2RayPort]
    
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.shared.set(encoded, forKey: UserDefaults.Key.v2RayPorts)
        }
    }
    
    static func load() -> V2RayPorts? {
        if let saved = UserDefaults.shared.object(forKey: UserDefaults.Key.v2RayPorts) as? Data {
            if let loaded = try? JSONDecoder().decode(V2RayPorts.self, from: saved) {
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

struct V2RayHost: Codable {
    let host: String
    let dnsName: String
    let v2ray: String
}
