//
//  NEVPNStatusTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 09/12/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest
import NetworkExtension

@testable import IVPNClient

class NEVPNStatusTests: XCTestCase {
    
    func test_isDisconnected() {
        var status: NEVPNStatus = .invalid
        XCTAssertTrue(status.isDisconnected())
        
        status = .disconnected
        XCTAssertTrue(status.isDisconnected())
        
        status = .connecting
        XCTAssertFalse(status.isDisconnected())
        
        status = .connected
        XCTAssertFalse(status.isDisconnected())
        
        status = .reasserting
        XCTAssertFalse(status.isDisconnected())
        
        status = .disconnecting
        XCTAssertFalse(status.isDisconnected())
    }
    
}
