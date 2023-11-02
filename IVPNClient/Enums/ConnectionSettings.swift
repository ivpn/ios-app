//
//  ConnectionSettings.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2018-07-16.
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

import Foundation

enum ConnectionSettings {
    
    case ipsec
    case openvpn(OpenVPNProtocol, Int)
    case wireguard(WireGuardProtocol, Int)
    
    func format() -> String {
        if UserDefaults.shared.isMultiHop {
            return formatMultiHop()
        }
        
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
            return "WireGuard, \(wireguardProtocol()) \(port)"
        }
    }
    
    func formatMultiHop() -> String {
        switch self {
        case .ipsec:
            return "IKEv2"
        case .openvpn(let proto, _):
            switch proto {
            case .tcp:
                return "OpenVPN, TCP"
            case .udp:
                return "OpenVPN, UDP"
           }
        case .wireguard(_, let port):
            if UserDefaults.shared.isV2ray {
                return "WireGuard, \(wireguardProtocol()) \(port)"
            }
            
            return "WireGuard, \(wireguardProtocol())"
        }
    }
    
    func formatSave() -> String {
        switch self {
        case .ipsec:
            return "ikev2"
        case .openvpn(let proto, let port):
            switch proto {
            case .tcp:
                return "openvpn-tcp-\(port)"
            case .udp:
                return "openvpn-udp-\(port)"
           }
        case .wireguard(_, let port):
            return "wireguard-udp-\(port)"
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
            return "\(wireguardProtocol()) \(port)"
        }
    }
    
    func formatProtocolMultiHop() -> String {
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
        case .wireguard(_, let port):
            if UserDefaults.shared.isV2ray {
                return "\(wireguardProtocol()) \(port)"
            }
            
            return "\(wireguardProtocol())"
        }
    }
    
   static func tunnelTypes(protocols: [ConnectionSettings]) -> [ConnectionSettings] {
        var filteredProtocols = [ConnectionSettings]()
        
        for protocolObj in protocols {
            var containsProtocol = false
            
            for filteredProtocol in filteredProtocols where filteredProtocol.tunnelType() == protocolObj.tunnelType() {
                containsProtocol = true
            }
            
            if !containsProtocol {
                filteredProtocols.append(protocolObj)
            }
        }
        
        return filteredProtocols
    }
    
    func supportedProtocols(protocols: [ConnectionSettings]) -> [ConnectionSettings] {
        var filteredProtocols = [ConnectionSettings]()
        
        for protocolObj in protocols where protocolObj.tunnelType() == self.tunnelType() {
            if UserDefaults.shared.isV2ray && tunnelType() == .wireguard && UserDefaults.shared.v2rayProtocol == protocolObj.storedProtocolType().lowercased() {
                if UserDefaults.shared.v2rayProtocol == protocolObj.storedProtocolType().lowercased() {
                    filteredProtocols.append(protocolObj)
                }
            } else {
                filteredProtocols.append(protocolObj)
            }
        }
        
        return filteredProtocols
    }
    
    func supportedProtocolsFormat(protocols: [ConnectionSettings]) -> [String] {
        let protocols = supportedProtocols(protocols: protocols)
        return protocols.map({ $0.formatProtocol() })
    }
    
    func supportedProtocolsFormatMultiHop() -> [String] {
        return ["UDP", "TCP"]
    }
    
    static func getSavedProtocol() -> ConnectionSettings {
        let portString = UserDefaults.standard.string(forKey: UserDefaults.Key.selectedProtocol) ?? ""
        return getFrom(portString: portString)
    }
    
    static func getFrom(portString: String) -> ConnectionSettings {
        var name = ""
        var proto = ""
        var port = 0
        let components = portString.components(separatedBy: "-")
        
        if let protocolName = components[safeIndex: 0] {
            name = protocolName
        }
        if let protocolType = components[safeIndex: 1] {
            proto = protocolType
        }
        if let protocolPort = components[safeIndex: 2] {
            port = Int(protocolPort) ?? 0
        }
        
        switch name {
        case "ikev2":
            return .ipsec
        case "openvpn":
            switch proto {
            case "tcp":
                return .openvpn(.tcp, port)
            case "udp":
                return .openvpn(.udp, port)
            default:
                return Config.defaultProtocol
            }
        case "wireguard":
            return .wireguard(.udp, port)
        default:
            return Config.defaultProtocol
        }
    }
    
    static func serversListKey() -> String {
        switch getSavedProtocol() {
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
            return wireguardProtocol()
        }
    }
    
    func storedProtocolType() -> String {
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
    
    func wireguardProtocol() -> String {
        if UserDefaults.shared.isV2ray && UserDefaults.shared.v2rayProtocol == "tcp" {
            return "TCP"
        }
        
        return "UDP"
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
    
}
