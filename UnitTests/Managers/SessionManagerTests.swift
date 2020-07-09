//
//  SessionManagerTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-07-30.
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
