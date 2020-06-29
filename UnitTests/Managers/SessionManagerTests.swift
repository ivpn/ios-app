//
//  SessionManagerTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 30/07/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class SessionManagerTests: XCTestCase {
    
    let sessionManager = SessionManager()
    
    override func setUp() {
        KeyChain.sessionToken = nil
    }
    
    override func tearDown() {
        KeyChain.sessionToken = nil
    }
    
    func test_sessionExists() {
        XCTAssertFalse(SessionManager.sessionExists)
        KeyChain.sessionToken = "9j4ynsp08jn29ebv6p2sj50i2d"
        XCTAssertTrue(SessionManager.sessionExists)
    }
    
}
