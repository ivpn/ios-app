//
//  V2RayConfig.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-08-04.
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

struct V2RayConfig: Codable {
    
    // MARK: - Properties -
    
    var log: Log
    var inbounds: [Inbound]
    var outbounds: [Outbound]
    
    struct Log: Codable {
        var loglevel: String
    }
    
    struct Inbound: Codable {
        var tag: String
        var port: String
        var listen: String
        var `protocol`: String
        var settings: Settings
        
        struct Settings: Codable {
            var address: String
            var port: Int
            var network: String
        }
    }
    
    struct Outbound: Codable {
        let tag: String
        let `protocol`: String
        var settings: Settings
        var streamSettings: StreamSettings
        
        struct Settings: Codable {
            var vnext: [Vnext]
            
            struct Vnext: Codable {
                var address: String
                var port: Int
                var users: [User]
                
                struct User: Codable {
                    var id: String
                    let alterId: Int
                    let security: String
                }
            }
        }
        
        struct StreamSettings: Codable {
            var network: String
            var security: String?
            var quicSettings: QuicSettings?
            var tlsSettings: TlsSettings?
            var tcpSettings: TcpSettings?
            
            struct QuicSettings: Codable {
                let security: String
                let key: String
                let header: Header
                
                struct Header: Codable {
                    let type: String
                }
            }
            
            struct TlsSettings: Codable {
                var serverName: String
            }
            
            struct TcpSettings: Codable {
                let header: Header
                
                struct Header: Codable {
                    let type: String
                    let request: Request
                    
                    struct Request: Codable {
                        let version: String
                        let method: String
                        let path: [String]
                        let headers: Headers
                        
                        struct Headers: Codable {
                            let host: [String]
                            let userAgent: [String]
                            let acceptEncoding: [String]
                            let connection: [String]
                            let pragma: String
                            
                            enum CodingKeys: String, CodingKey {
                                case host = "Host"
                                case userAgent = "User-Agent"
                                case acceptEncoding = "Accept-Encoding"
                                case connection = "Connection"
                                case pragma = "Pragma"
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Methods -
    
    func getLocalPort() -> (port: Int, isTcp: Bool) {
        guard inbounds.count > 0 else {
            return (0, false)
        }
        
        let port = Int(inbounds[0].port)!
        let isTcp = inbounds[0].settings.network == "tcp"
        return (port, isTcp)
    }
    
    mutating func setLocalPort(port: Int, isTcp: Bool) {
        guard inbounds.count > 0 else {
            return
        }
        
        inbounds[0].port = String(port)
        if isTcp {
            inbounds[0].settings.network = "tcp"
        } else {
            inbounds[0].settings.network = "udp"
        }
    }
    
    static func createFromTemplate(outboundIp: String, outboundPort: Int, inboundIp: String, inboundPort: Int, outboundUserId: String) -> V2RayConfig {
        var config = V2RayConfig.parse(fromJsonFile: "config")!
        config.inbounds[0].settings.address = inboundIp
        config.inbounds[0].settings.port = inboundPort
        config.outbounds[0].settings.vnext[0].address = outboundIp
        config.outbounds[0].settings.vnext[0].port = outboundPort
        config.outbounds[0].settings.vnext[0].users[0].id = outboundUserId
        
        return config
    }
    
    static func createQuick(outboundIp: String, outboundPort: Int, inboundIp: String, inboundPort: Int, outboundUserId: String, tlsSrvName: String) -> V2RayConfig {
        var config = createFromTemplate(outboundIp: outboundIp, outboundPort: outboundPort, inboundIp: inboundIp, inboundPort: inboundPort, outboundUserId: outboundUserId)
        config.outbounds[0].streamSettings.network = "quic"
        config.outbounds[0].streamSettings.tcpSettings = nil
        config.outbounds[0].streamSettings.tlsSettings?.serverName = tlsSrvName
        
        return config
    }
    
    static func createTcp(outboundIp: String, outboundPort: Int, inboundIp: String, inboundPort: Int, outboundUserId: String) -> V2RayConfig {
        var config = createFromTemplate(outboundIp: outboundIp, outboundPort: outboundPort, inboundIp: inboundIp, inboundPort: inboundPort, outboundUserId: outboundUserId)
        config.outbounds[0].streamSettings.network = "tcp"
        config.outbounds[0].streamSettings.security = ""
        config.outbounds[0].streamSettings.quicSettings = nil
        config.outbounds[0].streamSettings.tlsSettings = nil
        
        return config
    }
    
    func isValid() -> String? {
        let port = getLocalPort().port
        if port == 0 || inbounds[0].settings.network.isEmpty {
            return "inbounds[0].port or inbounds[0].settings.network has invalid value"
        }
        if inbounds[0].settings.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "inbounds[0].settings.address is empty"
        }
        if inbounds[0].settings.port == 0 {
            return "inbounds[0].settings.port is empty"
        }
        if outbounds[0].settings.vnext[0].address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "outbounds[0].settings.vnext[0].address is empty"
        }
        if outbounds[0].settings.vnext[0].port == 0 {
            return "outbounds[0].settings.vnext[0].port is empty"
        }
        if outbounds[0].settings.vnext[0].users[0].id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "outbounds[0].settings.vnext[0].users[0].id is empty"
        }
        
        return nil
    }
    
    func jsonString() -> String {
        var configString = "{}"
        do {
            let data = try JSONEncoder().encode(self)
            if let json = String(data: data, encoding: .utf8) {
                configString = json
            }
        } catch {}
        
        return configString
    }
    
}
