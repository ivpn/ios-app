//
//  DoubleTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 30/06/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class SomeTests: XCTestCase {
    
    func test_toRadian() {
        XCTAssertEqual(0.toRadian(), 0)
        XCTAssertEqual(10.toRadian(), 0.17453292519943295)
        XCTAssertEqual(30.toRadian(), 0.5235987755982988)
    }
    
}
