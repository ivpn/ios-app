//
//  ApplicationTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 30/06/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class ApplicationTests: XCTestCase {
    
    func test_clearSession() {
        Application.shared.serviceStatus.isActive = true
        Application.shared.clearSession()
        XCTAssertFalse(Application.shared.serviceStatus.isActive)
    }
    
}
