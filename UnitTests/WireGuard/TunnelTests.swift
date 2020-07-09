//
//  TunnelTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-02-11.
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

import XCTest

@testable import IVPNClient

class TunnelTests: XCTestCase {
    
    var tunnel = Tunnel()
    
    override func setUp() {
        super.setUp()
        
        let peer = Peer(
            publicKey: "fq5ijOijHkhkJWiWT3bC7jRGFfDQo+2EL5aCgGgW5Qw=",
            allowedIPs: "0.0.0.0/0",
            endpoint: Peer.endpoint(host: "145.239.239.55", port: 48574),
            persistentKeepalive: 25
        )
        let interface = Interface(
            addresses: "10.0.0.151",
            listenPort: 51820,
            privateKey: "+CRaGBKzRDMBCrkP6ETC8CzzASl97v1oZtMcfo/9pFg=",
            dns: "10.0.0.1"
        )
        tunnel = Tunnel(
            tunnelIdentifier: UIDevice.uuidString(),
            title: "IVPN WireGuard",
            interface: interface,
            peers: [peer]
        )
    }
    
    func test_generateProviderConfiguration() {
        let configuration = tunnel.generateProviderConfiguration()
        
        XCTAssertEqual(configuration["dns"] as! String, "10.0.0.1")
        XCTAssertEqual(configuration["addresses"] as! String, "10.0.0.151")
        XCTAssertEqual(configuration["endpoints"] as! String, "145.239.239.55:48574")
        XCTAssertEqual(configuration["title"] as! String, "IVPN WireGuard")
        XCTAssertEqual(configuration["settings"] as! String, "replace_peers=true\nprivate_key=f8245a1812b34433010ab90fe844c2f02cf301297deefd6866d31c7e8ffda458\nlisten_port=51820\npublic_key=7eae628ce8a31e48642568964f76c2ee344615f0d0a3ed842f9682806816e50c\nendpoint=145.239.239.55:48574\npersistent_keepalive_interval=25\nallowed_ip=0.0.0.0/0\n")
    }
    
}
