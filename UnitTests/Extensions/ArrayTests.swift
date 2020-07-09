//
//  ArrayTests.swift
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

class ArrayTests: XCTestCase {
    
    let array = [1, 2]
    
    func test_safeSubscript() {
        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 1], 2)
        XCTAssertEqual(array[safe: 2], nil)
    }
    
    func test_next() {
        let hostNames = ["1.1.1.1", "2.2.2.2"]
        
        if let nextHost = hostNames.next(item: "1.1.1.1") {
            XCTAssertEqual(nextHost, "2.2.2.2")
        } else {
            XCTFail("Next element not found")
        }
        
        XCTAssertNil(hostNames.next(item: "2.2.2.2"), "There should be no next element")
    }
    
    func test_move() {
        var hostNames = ["ivpn.net", "1.1.1.1", "2.2.2.2"]
        
        hostNames.move("ivpn.net", to: 0)
        XCTAssertEqual(hostNames, ["ivpn.net", "1.1.1.1", "2.2.2.2"])
        
        hostNames.move("1.1.1.1", to: 0)
        XCTAssertEqual(hostNames, ["1.1.1.1", "ivpn.net", "2.2.2.2"])
        
        hostNames.move("2.2.2.2", to: 0)
        XCTAssertEqual(hostNames, ["2.2.2.2", "1.1.1.1", "ivpn.net"])
    }
    
}
