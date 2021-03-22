//
//  SecureDNSTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-02-17.
//  Copyright (c) 2021 Privatus Limited.
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

import XCTest

@testable import IVPNClient

class SecureDNSTests: XCTestCase {
    
    var model = SecureDNS()
    
    override func setUp() {
        model = SecureDNS()
    }
    
    func test_validation() {
        model.address = nil
        XCTAssertFalse(model.validation().0)
        XCTAssertEqual(model.validation().1, "Please enter DNS server info")
        
        model.address = "0.0.0.0"
        XCTAssertTrue(model.validation().0)
        XCTAssertNil(model.validation().1)
        
        model.address = "https://example.com"
        XCTAssertTrue(model.validation().0)
        XCTAssertNil(model.validation().1)
        
        model.address = "example.com"
        XCTAssertTrue(model.validation().0)
        XCTAssertNil(model.validation().1)
    }
    
    func test_getServerURL() {
        model.address = "0.0.0.0"
        XCTAssertEqual(model.serverURL, "https://0.0.0.0/dns-query")
        
        model.address = "https://0.0.0.0"
        XCTAssertEqual(model.serverURL, "https://0.0.0.0")
        
        model.address = "0.0.0.0/dns-query"
        XCTAssertEqual(model.serverURL, "https://0.0.0.0/dns-query")
        
        model.address = "https://0.0.0.0/dns-query"
        XCTAssertEqual(model.serverURL, "https://0.0.0.0/dns-query")
        
        model.address = "example.com"
        XCTAssertEqual(model.serverURL, "https://example.com/dns-query")
        
        model.address = "https://example.com"
        XCTAssertEqual(model.serverURL, "https://example.com")
        
        model.address = "example.com/dns-query"
        XCTAssertEqual(model.serverURL, "https://example.com/dns-query")
        
        model.address = "https://example.com/dns-query"
        XCTAssertEqual(model.serverURL, "https://example.com/dns-query")
        
        model.address = "https://example.com/123456"
        XCTAssertEqual(model.serverURL, "https://example.com/123456")
        
        model.address = "https://123456.example.com"
        XCTAssertEqual(model.serverURL, "https://123456.example.com")
    }
    
    func test_getServerName() {
        model.address = "0.0.0.0"
        XCTAssertEqual(model.serverName, "0.0.0.0")
        
        model.address = "https://0.0.0.0"
        XCTAssertEqual(model.serverName, "0.0.0.0")
        
        model.address = "0.0.0.0/dns-query"
        XCTAssertEqual(model.serverName, "0.0.0.0")
        
        model.address = "https://0.0.0.0/dns-query"
        XCTAssertEqual(model.serverName, "0.0.0.0")
        
        model.address = "example.com"
        XCTAssertEqual(model.serverName, "example.com")
        
        model.address = "https://example.com"
        XCTAssertEqual(model.serverName, "example.com")
        
        model.address = "example.com/dns-query"
        XCTAssertEqual(model.serverName, "example.com")
        
        model.address = "https://example.com/dns-query"
        XCTAssertEqual(model.serverName, "example.com")
        
        model.address = "subdomain.example.com"
        XCTAssertEqual(model.serverName, "subdomain.example.com")
        
        model.address = "subdomain.subdomain.example.com"
        XCTAssertEqual(model.serverName, "subdomain.subdomain.example.com")
    }
    
    func test_getServerToResolve() {
        var server = DNSProtocolType.getServerToResolve(address: "0.0.0.0")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerToResolve(address: "https://0.0.0.0")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerToResolve(address: "0.0.0.0/dns-query")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerToResolve(address: "https://0.0.0.0/dns-query")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerToResolve(address: "example.com")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerToResolve(address: "https://example.com")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerToResolve(address: "example.com/dns-query")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerToResolve(address: "https://example.com/dns-query")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerToResolve(address: "subdomain.example.com")
        XCTAssertEqual(server, "subdomain.example.com")
        
        server = DNSProtocolType.getServerToResolve(address: "subdomain.subdomain.example.com")
        XCTAssertEqual(server, "subdomain.example.com")
    }
    
}
