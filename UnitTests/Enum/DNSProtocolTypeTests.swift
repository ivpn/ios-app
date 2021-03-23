//
//  DNSProtocolTypeTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-03-22.
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

class DNSProtocolTypeTests: XCTestCase {
    
    func test_getServerURL() {
        var server = DNSProtocolType.getServerURL(address: "0.0.0.0")
        XCTAssertEqual(server, "https://0.0.0.0/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "https://0.0.0.0")
        XCTAssertEqual(server, "https://0.0.0.0/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "0.0.0.0/dns-query")
        XCTAssertEqual(server, "https://0.0.0.0/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "https://0.0.0.0/dns-query")
        XCTAssertEqual(server, "https://0.0.0.0/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "example.com")
        XCTAssertEqual(server, "https://example.com/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "https://example.com")
        XCTAssertEqual(server, "https://example.com/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "example.com/dns-query")
        XCTAssertEqual(server, "https://example.com/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "https://example.com/dns-query")
        XCTAssertEqual(server, "https://example.com/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "subdomain.example.com")
        XCTAssertEqual(server, "https://subdomain.example.com/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "subdomain.subdomain.example.com")
        XCTAssertEqual(server, "https://subdomain.subdomain.example.com/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "example.com/")
        XCTAssertEqual(server, "https://example.com/dns-query")
        
        server = DNSProtocolType.getServerURL(address: "example.com/123456")
        XCTAssertEqual(server, "https://example.com/123456")
        
        server = DNSProtocolType.getServerURL(address: "")
        XCTAssertEqual(server, "")
    }
    
    func test_getServerName() {
        var server = DNSProtocolType.getServerName(address: "0.0.0.0")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerName(address: "https://0.0.0.0")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerName(address: "0.0.0.0/dns-query")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerName(address: "https://0.0.0.0/dns-query")
        XCTAssertEqual(server, "0.0.0.0")
        
        server = DNSProtocolType.getServerName(address: "example.com")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerName(address: "https://example.com")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerName(address: "example.com/dns-query")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerName(address: "https://example.com/dns-query")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.getServerName(address: "subdomain.example.com")
        XCTAssertEqual(server, "subdomain.example.com")
        
        server = DNSProtocolType.getServerName(address: "subdomain.subdomain.example.com")
        XCTAssertEqual(server, "subdomain.subdomain.example.com")
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
    
    func test_sanitizeServer() {
        var server = DNSProtocolType.sanitizeServer(address: " tls://example.com ")
        XCTAssertEqual(server, "example.com")
        
        server = DNSProtocolType.sanitizeServer(address: " https://example.com ")
        XCTAssertEqual(server, "example.com")
    }
    
}
