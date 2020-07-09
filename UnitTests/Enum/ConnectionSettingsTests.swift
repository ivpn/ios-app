//
//  ConnectionSettingsTests.swift
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

class ConnectionSettingsTests: XCTestCase {
    
    let protocols = [
        ConnectionSettings.ipsec,
        ConnectionSettings.openvpn(OpenVPNProtocol.udp, 53),
        ConnectionSettings.openvpn(OpenVPNProtocol.udp, 2049),
        ConnectionSettings.openvpn(OpenVPNProtocol.udp, 2050),
        ConnectionSettings.openvpn(OpenVPNProtocol.tcp, 80),
        ConnectionSettings.openvpn(OpenVPNProtocol.tcp, 443),
        ConnectionSettings.openvpn(OpenVPNProtocol.tcp, 1443),
        ConnectionSettings.wireguard(WireGuardProtocol.udp, 48574)
    ]
    
    let protocol1 = ConnectionSettings.ipsec
    let protocol2 = ConnectionSettings.openvpn(OpenVPNProtocol.udp, 53)
    let protocol3 = ConnectionSettings.openvpn(OpenVPNProtocol.tcp, 80)
    let protocol4 = ConnectionSettings.wireguard(WireGuardProtocol.udp, 48574)
    
    func test_format() {
        XCTAssertEqual(protocol1.format(), "IKEv2")
        XCTAssertEqual(protocol2.format(), "OpenVPN, UDP 53")
        XCTAssertEqual(protocol3.format(), "OpenVPN, TCP 80")
        XCTAssertEqual(protocol4.format(), "WireGuard, UDP 48574")
    }
    
    func test_formatTitle() {
        XCTAssertEqual(protocol1.formatTitle(), "IKEv2")
        XCTAssertEqual(protocol2.formatTitle(), "OpenVPN")
        XCTAssertEqual(protocol4.formatTitle(), "WireGuard")
    }
    
    func test_formatProtocol() {
        XCTAssertEqual(protocol1.formatProtocol(), "IKEv2")
        XCTAssertEqual(protocol2.formatProtocol(), "UDP 53")
        XCTAssertEqual(protocol3.formatProtocol(), "TCP 80")
        XCTAssertEqual(protocol4.formatProtocol(), "UDP 48574")
    }
    
    func test_tunnelTypest() {
        let tunnelTypes = ConnectionSettings.tunnelTypes(protocols: protocols)
        XCTAssertEqual(tunnelTypes.count, 3)
    }
    
    func test_supportedProtocols() {
        XCTAssertEqual(protocol1.supportedProtocols(protocols: protocols).count, 1)
        XCTAssertEqual(protocol2.supportedProtocols(protocols: protocols).count, 6)
        XCTAssertEqual(protocol3.supportedProtocols(protocols: protocols).count, 6)
        XCTAssertEqual(protocol4.supportedProtocols(protocols: protocols).count, 1)
    }
    
    func test_supportedProtocolsFormat() {
        XCTAssertEqual(protocol1.supportedProtocolsFormat(protocols: protocols).count, 1)
        XCTAssertEqual(protocol4.supportedProtocols(protocols: protocols).count, 1)
        XCTAssertEqual(protocol4.supportedProtocolsFormat(protocols: protocols), ["UDP 2049", "UDP 2050", "UDP 53", "UDP 1194", "UDP 30587", "UDP 41893", "UDP 48574", "UDP 58237"])
    }
    
    func test_tunnelType() {
        XCTAssertEqual(protocol1.tunnelType(), .ipsec)
        XCTAssertEqual(protocol2.tunnelType(), .openvpn)
        XCTAssertEqual(protocol3.tunnelType(), .openvpn)
        XCTAssertEqual(protocol4.tunnelType(), .wireguard)
    }
    
    func test_port() {
        XCTAssertEqual(protocol1.port(), 500)
        XCTAssertEqual(protocol2.port(), 53)
        XCTAssertEqual(protocol3.port(), 80)
        XCTAssertEqual(protocol4.port(), 48574)
    }
    
    func test_protocolType() {
        XCTAssertEqual(protocol1.protocolType(), "IKEv2")
        XCTAssertEqual(protocol2.protocolType(), "UDP")
        XCTAssertEqual(protocol3.protocolType(), "TCP")
        XCTAssertEqual(protocol4.protocolType(), "UDP")
    }
    
    func test_equatable() {
        XCTAssertFalse(protocol1 == protocol2)
        XCTAssertFalse(protocol2 == protocol3)
        XCTAssertTrue(protocol2 == protocol2)
    }
    
}
