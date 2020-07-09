//
//  Peer.swift
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
