//
//  KeyChainTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-07-29.
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

class KeyChainTests: XCTestCase {
    
    override func tearDown() {
        KeyChain.username = nil
        KeyChain.vpnUsername = nil
        KeyChain.vpnPassword = nil
    }
    
    func test_vpnUsername() {
        KeyChain.vpnUsername = nil
        KeyChain.username = "username"
        XCTAssertEqual(KeyChain.vpnUsername, nil)
        
        KeyChain.vpnUsername = "vpnUsername"
        XCTAssertEqual(KeyChain.vpnUsername, "vpnUsername")
    }
    
    func test_vpnPassword() {
        KeyChain.vpnPassword = nil
        XCTAssertEqual(KeyChain.vpnPassword, nil)
        
        KeyChain.vpnPassword = "vpnPassword"
        XCTAssertEqual(KeyChain.vpnPassword, "vpnPassword")
    }
    
}
