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
        model.ipAddress = nil
        XCTAssertFalse(model.validation().0)
        XCTAssertEqual(model.validation().1, "Please enter DNS server ip address")
        
        model.ipAddress = "0.0.0.0"
        model.type = "doh"
        model.serverURL = nil
        XCTAssertFalse(model.validation().0)
        XCTAssertEqual(model.validation().1, "Please enter DNS server URL")
        
        model.serverURL = "https://example.com"
        XCTAssertTrue(model.validation().0)
        
        model.type = "dot"
        model.serverName = nil
        XCTAssertFalse(model.validation().0)
        XCTAssertEqual(model.validation().1, "Please enter DNS server name")
        
        model.serverName = "example.com"
        XCTAssertTrue(model.validation().0)
    }
    
}
