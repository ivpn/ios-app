//
//  PortRange.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-07-15.
//  Copyright (c) 2022 Privatus Limited.
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

struct PortRange {
    var tunnelType: String
    var protocolType: String
    var ranges: [String]
    
    var storeKey: String {
        if tunnelType == "OpenVPN" {
            if protocolType == "TCP" {
                return UserDefaults.Key.openvpnTcpCustomPort
            } else {
                return UserDefaults.Key.openvpnUdpCustomPort
            }
        }
        
        return UserDefaults.Key.wireguardCustomPort
    }
    
    var portRangesText: String {
        return ranges.joined(separator: ", ").replacingOccurrences(of: ":", with: "-")
    }
    
    func save(port: Int) -> String? {
        if port > 0 {
            if isValid(port: port) {
                UserDefaults.standard.set(port, forKey: storeKey)
            } else {
                return "Enter a port number within the range: \(portRangesText)"
            }
        } else {
            UserDefaults.standard.removeObject(forKey: storeKey)
        }
        UserDefaults.standard.synchronize()
        
        return nil
    }
    
    func isValid(port: Int) -> Bool {
        for range in ranges {
            if let rangeStart = Int(range.split(separator: ":")[0]), let rangeEnd = Int(range.split(separator: ":")[1]) {
                let portRange = rangeStart...rangeEnd
                if portRange.contains(port) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func validate(port: Int) -> String? {
        for range in ranges {
            if let rangeStart = Int(range.split(separator: ":")[0]), let rangeEnd = Int(range.split(separator: ":")[1]) {
                let portRange = rangeStart...rangeEnd
                if portRange.contains(port) {
                    return nil
                }
            }
        }
        
        return "Enter port number in the range: \(portRangesText)"
    }
    
    func getSavedPort() -> Int? {
        let port = UserDefaults.standard.integer(forKey: storeKey)
        return port > 0 ? port : nil
    }
    
    static func getPorts(from portRanges: [PortRange], tunnelType: String) -> [ConnectionSettings] {
        var ports = [ConnectionSettings]()
        
        if tunnelType == "OpenVPN" {
            let udpPort = UserDefaults.standard.integer(forKey: UserDefaults.Key.openvpnUdpCustomPort)
            let tcpPort = UserDefaults.standard.integer(forKey: UserDefaults.Key.openvpnTcpCustomPort)
            if udpPort > 0 {
                ports.append(ConnectionSettings.openvpn(.udp, udpPort))
            }
            if tcpPort > 0 {
                ports.append(ConnectionSettings.openvpn(.tcp, tcpPort))
            }
        }
        
        if tunnelType == "WireGuard" {
            let port = UserDefaults.standard.integer(forKey: UserDefaults.Key.wireguardCustomPort)
            if port > 0 {
                ports.append(ConnectionSettings.wireguard(.udp, port))
            }
        }
        
        return ports
    }
    
}
