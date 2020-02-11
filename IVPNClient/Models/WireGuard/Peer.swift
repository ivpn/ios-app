//
//  Peer.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 15/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

struct Peer {
    
    // MARK: - Properties -
    
    var publicKey: String?
    var presharedKey: String?
    var allowedIPs: String?
    var endpoint: String?
    var persistentKeepalive: Int32
    var tunnel: Tunnel?
    
    // MARK: - Initialize -
    
    public init(publicKey: String? = nil, presharedKey: String? = nil, allowedIPs: String? = nil, endpoint: String? = nil, persistentKeepalive: Int32 = 0, tunnel: Tunnel? = nil) {
        self.publicKey = publicKey
        self.presharedKey = presharedKey
        self.allowedIPs = allowedIPs
        self.endpoint = endpoint
        self.persistentKeepalive = persistentKeepalive
        self.tunnel = tunnel
    }
    
    // MARK: - Methods -
    
    static func endpoint(host: String, port: Int) -> String {
        return "\(host):\(port)"
    }
    
}
