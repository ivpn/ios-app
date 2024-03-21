//
//  TunnelKit+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2024-01-03.
//  Copyright (c) 2024 IVPN Limited.
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
import TunnelKitCore
import TunnelKitOpenVPN

extension OpenVPN {
    
    struct Config {
        
        struct Parameters {
            let title: String
            let appGroup: String
            let hostname: String
            let port: UInt16
            let socketType: SocketType
            let dnsServers: [String]?
            let dnsProtocol: DNSProtocolType
            let customDNS: String
        }
        
        static func make(params: Parameters) -> OpenVPN.ProviderConfiguration {
            let tlsKey = OpenVPN.StaticKey(file: OpenVPNConf.tlsAuth, direction: .client)!
            
            var builder = OpenVPN.ConfigurationBuilder()
            builder.ca = OpenVPN.CryptoContainer(pem: OpenVPNConf.caCert)
            builder.cipher = .aes256cbc
            builder.compressionFraming = .disabled
            builder.remotes = [Endpoint(params.hostname, EndpointProtocol(params.socketType, params.port))]
            builder.tlsWrap = TLSWrap(strategy: .auth, key: tlsKey)
            builder.routingPolicies = [.IPv4, .IPv6]
            
            if let dnsServers = params.dnsServers, !dnsServers.isEmpty, dnsServers != [""] {
                builder.dnsServers = dnsServers
                
                switch params.dnsProtocol {
                case .doh:
                    builder.dnsProtocol = .https
                    builder.dnsHTTPSURL = URL.init(string: DNSProtocolType.getServerURL(address: params.customDNS))
                case .dot:
                    builder.dnsProtocol = .tls
                    builder.dnsTLSServerName = DNSProtocolType.getServerName(address: params.customDNS)
                default:
                    builder.dnsProtocol = .plain
                }
            }
            
            let cfg = builder.build()
            
            var configuration = OpenVPN.ProviderConfiguration(params.title, appGroup: params.appGroup, configuration: cfg)
            configuration.shouldDebug = true
            configuration.debugLogFormat = "$Dyyyy-MM-dd HH:mm:ss$d $L $M"
            configuration.masksPrivateData = true
            configuration.debugLogPath = FileManager.openvpnLogTextFileURL?.lastPathComponent
            
            return configuration
        }
        
    }
    
}
