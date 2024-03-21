//
//  Config.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda
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

import UIKit

struct Config {
    
    static let useDebugServers = false
    static let useDebugWireGuardKeyUpgrade = false
    static let minPingCheckInterval: TimeInterval = 10
    static let appGroup = "group.net.ivpn.clients.ios"
    
    static let apiServersFile = "/v5/servers.json"
    static let apiGeoLookup = "/v4/geo-lookup"
    static let apiSessionNew = "/v4/session/new"
    static let apiSessionStatus = "/v4/session/status"
    static let apiSessionDelete = "/v4/session/delete"
    static let apiSessionWGKeySet = "/v4/session/wg/set"
    static let apiAccountNew = "/v4/account/new"
    static let apiPaymentInitial = "/v4/account/payment/ios/initial"
    static let apiPaymentAdd = "/v4/account/payment/ios/add"
    static let apiPaymentAddLegacy = "/v2/mobile/ios/subscription-purchased"
    static let apiPaymentRestore = "/v4/account/payment/ios/restore"
    
    static let urlTypeLogin = "login"
    static let urlTypeConnect = "connect"
    static let urlTypeDisconnect = "disconnect"
    
    static let ikev2TunnelTitle = "IVPN IKEv2"
    static let openvpnTunnelProvider = "net.ivpn.clients.ios.openvpn-tunnel-provider"
    static let openvpnTunnelTitle = "IVPN OpenVPN"
    static let wireguardTunnelProvider = "net.ivpn.clients.ios.wireguard-tunnel-provider"
    static let wireguardTunnelTitle = "IVPN WireGuard"
    
    // Files and Directories
    static let serversListCacheFileName = "servers_cache1.json"
    static let appLogFile = "AppLogs.txt"
    static let openVPNLogFile = "OpenVPNLogs.txt"
    static let wireGuardLogFile = "WireGuardLogs.txt"
    
    // Contact Support web page
    static let contactSupportMail = "support@ivpn.net"
    static let contactSupportPage = "mailto:support@ivpn.net"
    
    static let serviceStatusRefreshMaxIntervalSeconds: TimeInterval = 30
    static let stableVPNStatusInterval: TimeInterval = 0.5
    
    static let defaultProtocol = ConnectionSettings.wireguard(.udp, 2049)
    static let supportedProtocolTypes = [
        ConnectionSettings.wireguard(.udp, 2049),
        ConnectionSettings.ipsec,
        ConnectionSettings.openvpn(.udp, 2049)
    ]
    
    // MARK: WireGuard
    
    static let wgPeerAllowedIPs = "0.0.0.0/0,::/0"
    static let wgPeerPersistentKeepalive: Int32 = 25
    static let wgInterfaceListenPort = 51820
    static let wgKeyExpirationDays = 30
    static let wgKeyRegenerationRate = 1
    
    // MARK: V2Ray
    
    static let v2rayHost = "127.0.0.1"
    static let v2rayPort = 16661
    
    // MARK: ENV variables
    
    static var Environment: String {
        return value(for: "Environment")
    }
    
    static var ApiHostName: String {
        return value(for: "ApiHostName")
    }
    
    static var TlsHostName: String {
        return value(for: "TlsHostName")
    }
    
    // MARK: ENV .xcconfig parser
    
    static func value<T>(for key: String) -> T {
        guard let value = Bundle.main.infoDictionary?[key] as? T else {
            fatalError("Invalid or missing Info.plist key: \(key)")
        }
        
        return value
    }
    
    // MARK: Log files
    
    static let maxBytes = 100000
    
}
