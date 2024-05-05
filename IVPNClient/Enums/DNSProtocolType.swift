//
//  DNSProtocolType.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-03-10.
//  Copyright (c) 2021 IVPN Limited.
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

enum DNSProtocolType: String {
    
    case doh
    case dot
    case plain
    
    static func getServerURL(address: String) -> String {
        guard !address.trim().isEmpty else {
            return ""
        }
        
        var serverURL = address
        
        if !address.hasPrefix("https://") {
            serverURL = "https://\(serverURL)"
        }
        
        if let url = URL.init(string: serverURL) {
            if url.path.deletingPrefix("/").isEmpty {
                serverURL = "\(serverURL.deletingSuffix("/"))/dns-query"
            }
        }
        
        return serverURL
    }
    
    static func getServerName(address: String) -> String {
        var serverName = address
        
        if !address.hasPrefix("https://") {
            serverName = "https://\(serverName)"
        }
        
        if let url = URL.init(string: serverName) {
            if let host = url.host {
                do {
                    let ipAddress = try CIDRAddress(stringRepresentation: host)
                    return ipAddress?.ipAddress ?? address
                } catch {}
                
                return host
            }
        }
        
        return address
    }
    
    static func getServerToResolve(address: String) -> String {
        var serverName = address
        
        if !address.hasPrefix("https://") {
            serverName = "https://\(serverName)"
        }
        
        if let serverURL = URL.init(string: serverName) {
            if let host = serverURL.host {
                do {
                    let ipAddress = try CIDRAddress(stringRepresentation: host)
                    return ipAddress?.ipAddress ?? address
                } catch {}
                
                return serverURL.getTopLevelSubdomain()
            }
        }
        
        return address
    }
    
    static func sanitizeServer(address: String) -> String {
        return address.trim().deletingPrefix("https://").deletingPrefix("tls://")
    }
    
    static func preferred() -> DNSProtocolType {
        guard !UserDefaults.shared.isAntiTracker else {
            return .plain
        }
        
        return DNSProtocolType.init(rawValue: UserDefaults.shared.customDNSProtocol) ?? .plain
    }
    
    static func preferredSettings() -> DNSProtocolType {
        return DNSProtocolType.init(rawValue: UserDefaults.shared.customDNSProtocol) ?? .plain
    }
    
    static func save(preferred: DNSProtocolType) {
        UserDefaults.shared.setValue(preferred.rawValue, forKey: UserDefaults.Key.customDNSProtocol)
    }
    
}
