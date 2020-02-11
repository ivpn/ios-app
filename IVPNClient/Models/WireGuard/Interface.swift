//
//  Interface.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 15/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

struct Interface {
    
    // MARK: - Properties -
    
    var addresses: String?
    var listenPort: Int
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
    
    init(addresses: String? = nil, listenPort: Int = 0, privateKey: String? = nil, dns: String? = nil) {
        self.addresses = addresses
        self.listenPort = listenPort
        self.privateKey = privateKey
        self.dns = dns
    }
    
    init?(_ dict: NSDictionary) {
        if let ipAddress = dict.value(forKey: "ip_address") as? String {
            self.addresses = ipAddress
        } else {
            log(error: "Cannot create Interface: no 'ip_address' field specified")
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
    
}
