//
//  KeyChainTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 29/07/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class KeyChainTests: XCTestCase {
    
    override func tearDown() {
        KeyChain.username = nil
        KeyChain.vpnUsername = nil
        KeyChain.vpnPassword = nil
    }
    
    func testVpnUsername() {
        KeyChain.vpnUsername = nil
        KeyChain.username = "username"
        XCTAssertEqual(KeyChain.vpnUsername, nil)
        
        KeyChain.vpnUsername = "vpnUsername"
        XCTAssertEqual(KeyChain.vpnUsername, "vpnUsername")
    }
    
    func testVpnPassword() {
        KeyChain.vpnPassword = nil
        XCTAssertEqual(KeyChain.vpnPassword, nil)
        
        KeyChain.vpnPassword = "vpnPassword"
        XCTAssertEqual(KeyChain.vpnPassword, "vpnPassword")
    }
    
}
