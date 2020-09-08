//
//  StringTests.swift
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

class StringTests: XCTestCase {
    
    func test_commaSeparatedStringFrom() {
        XCTAssertEqual(String.commaSeparatedStringFrom(elements: ["a", "b", "c"]), "a,b,c")
    }
    
    func test_commaSeparatedToArray() {
        XCTAssertEqual("a,b,c".commaSeparatedToArray(), ["a", "b", "c"])
        XCTAssertEqual("a, b, c".commaSeparatedToArray(), ["a", "b", "c"])
    }
    
    func test_trim() {
        let user1 = "  username  "
        let user2 = " user name "
        let user3 = "username"
        
        XCTAssertEqual(user1.trim(), "username")
        XCTAssertEqual(user2.trim(), "user name")
        XCTAssertEqual(user3.trim(), "username")
    }
    
    func test_base64KeyToHex() {
        XCTAssertEqual("=".base64KeyToHex(), nil)
        XCTAssertEqual("+CRaGBKzRDMBCrkP6ETC8CzzASl97v1oZtMcfo/9pFg=".base64KeyToHex(), "f8245a1812b34433010ab90fe844c2f02cf301297deefd6866d31c7e8ffda458")
    }
    
    func test_camelCaseToCapitalized() {
        XCTAssertEqual("dnsFailure".camelCaseToCapitalized(), "Dns Failure")
        XCTAssertEqual("tlsServerVerification".camelCaseToCapitalized(), "Tls Server Verification")
        XCTAssertEqual("authentication".camelCaseToCapitalized(), "Authentication")
    }
    
}
