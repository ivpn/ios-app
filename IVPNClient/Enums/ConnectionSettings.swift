//
//  ConnectionSettings.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2018-07-16.
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

import Foundation

enum ConnectionSettings {
    
    case ipsec
    case openvpn(OpenVPNProtocol, Int)
    case wireguard(WireGuardProtocol, Int)
    
    func format() -> String {
        switch self {
        case .ipsec:
            return "IKEv2"
        case .openvpn(let proto, let port):
            switch proto {
            case .tcp:
                return "OpenVPN, TCP \(port)"
            case .udp:
                return "OpenVPN, UDP \(port)"
           }
        case .wireguard(_, let port):
            return "WireGuard, UDP \(port)"
        }
    }
    
    func formatTitle() -> String {
        switch self {
        case .ipsec:
            return "IKEv2"
        case .openvpn:
            return "OpenVPN"
        case .wireguard:
            return "WireGuard"
        }
    }
    
    func formatProtocol() -> String {
        switch self {
        case .ipsec:
            return "IKEv2"
        case .openvpn(let proto, let port):
            switch proto {
            case .tcp:
                return "TCP \(port)"
            case .udp:
                return "UDP \(port)"
            }
        case .wireguard(_, let port):
            return "UDP \(port)"
        }
    }
    
   static func tunnelTypes(protocols: [ConnectionSettings]) -> [ConnectionSettings] {
        var filteredProtocols = [ConnectionSettings]()
        
        for protocolObj in protocols {
            var containsProtocol = false
            
            for filteredProtocol in filteredProtocols {
                if filteredProtocol.tunnelType() == protocolObj.tunnelType() {
                    containsProtocol = true
                }
            }
            
            if !containsProtocol {
                filteredProtocols.append(protocolObj)
            }
        }
        
        return filteredProtocols
    }
    
    func supportedProtocols(protocols: [ConnectionSettings]) -> [ConnectionSettings] {
        var filteredProtocols = [ConnectionSettings]()
        
        for protocolObj in protocols {
            if protocolObj.tunnelType() == self.tunnelType() {
                filteredProtocols.append(protocolObj)
            }
        }
        
        return filteredProtocols
    }
    
    func supportedProtocolsFormat(protocols: [ConnectionSettings]) -> [String] {
        let protocols = supportedProtocols(protocols: Config.supportedProtocols)
        return protocols.map({ $0.formatProtocol() })
    }
    
    static func serversListKey() -> String {
        let index = UserDefaults.standard.integer(forKey: "selectedProtocolIndex")
        let connectionProtocol = Config.supportedProtocols[index]
        
        switch connectionProtocol {
        case .ipsec: return "openvpn"
        case .openvpn: return "openvpn"
        case .wireguard: return "wireguard"
        }
    }
    
    func tunnelType() -> TunnelType {
        switch self {
        case .ipsec:
            return TunnelType.ipsec
        case .openvpn:
            return TunnelType.openvpn
        case .wireguard:
            return TunnelType.wireguard
        }
    }
    
    func port() -> Int {
        switch self {
        case .ipsec:
            return 500
        case .openvpn(_, let port):
            return port
        case .wireguard(_, let port):
            return port
        }
    }
    
    func protocolType() -> String {
        switch self {
        case .ipsec:
            return "IKEv2"
        case .openvpn(let proto, _):
            switch proto {
            case .tcp:
                return "TCP"
            case .udp:
                return "UDP"
            }
        case .wireguard:
            return "UDP"
        }
    }
    
    static func == (lhs: ConnectionSettings, rhs: ConnectionSettings) -> Bool {
        switch (lhs, rhs) {
        case (.ipsec, .ipsec):
            return true
        case (.openvpn(let proto, let port), .openvpn(let proto2, let port2)):
            return (proto == proto2 && port == port2)
        case (.wireguard(let proto, let port), .wireguard(let proto2, let port2)):
            return (proto == proto2 && port == port2)
        default:
            return false
        }
    }
    
    static func != (lhs: ConnectionSettings, rhs: ConnectionSettings) -> Bool {
        return !(lhs == rhs)
    }
    
}
