//
//  Interface.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-15.
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
import Network

struct Interface {
    
    // MARK: - Properties -
    
    var addresses: String?
    var listenPort: Int
    var mtu: Int?
    var privateKey: String?
    var dns: String?
    
    var publicKey: String? {
        if let privateKeyString = privateKey, let privateKey = Data(base64Encoded: privateKeyString) {
            var publicKey = Data(count: 32)
            privateKey.withUnsafeUInt8Bytes { privateKeyBytes in
                publicKey.withUnsafeMutableUInt8Bytes { mutableBytes in
                    curve25519_derive_public_key(mutableBytes, privateKeyBytes)
                }
            }
            return publicKey.base64EncodedString()
        } else {
            return nil
        }
    }
    
    // MARK: - Initialize -
    
    init(addresses: String? = nil, listenPort: Int = 0, mtu: Int = 0, privateKey: String? = nil, dns: String? = nil) {
        self.addresses = addresses
        self.listenPort = listenPort
        self.mtu = mtu
        self.privateKey = privateKey
        self.dns = dns
    }
    
    init?(_ dict: NSDictionary) {
        if let ipAddress = dict.value(forKey: "ip_address") as? String {
            self.addresses = ipAddress
        } else {
            return nil
        }
        
        listenPort = 0
    }
    
    // MARK: - Methods -
    
    static func generatePrivateKey() -> String {
        var privateKey = Data(count: 32)
        privateKey.withUnsafeMutableUInt8Bytes { mutableBytes in
            curve25519_generate_private_key(mutableBytes)
        }
        
        return privateKey.base64EncodedString()
    }
    
    static func getAddresses(ipv4: String?, ipv6: String?) -> String {
        guard let ipv4 = ipv4 else {
            return ""
        }
        
        guard let ipv6 = ipv6 else {
            return ipv4
        }
        
        let ipv6Address = IPv6Address("\(ipv6.components(separatedBy: "/")[0])\(ipv4)")
        
        return "\(ipv4),\(ipv6Address?.debugDescription ?? "")/64"
    }
    
}
