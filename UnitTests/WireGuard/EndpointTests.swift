//
//  EndpointTests.swift
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

class EndpointTests: XCTestCase {
    
    func test_init() {
        let endpoint1 = ((try? Endpoint(endpointString: "10.0.0.0:53")) as Endpoint??)
        XCTAssertEqual(endpoint1??.ipAddress, "10.0.0.0")
        XCTAssertEqual(endpoint1??.port, 53)
        XCTAssertEqual(endpoint1??.addressType, .IPv4)
        
        let endpoint2 = ((try? Endpoint(endpointString: "[2001:db8:a0b:12f0::1]:21")) as Endpoint??)
        XCTAssertEqual(endpoint2??.ipAddress, "2001:db8:a0b:12f0::1")
        XCTAssertEqual(endpoint2??.port, 21)
        XCTAssertEqual(endpoint2??.addressType, .IPv6)
    }
    
}
