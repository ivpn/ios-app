//
//  InterfaceTests.swift
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

class InterfaceTests: XCTestCase {
    
    var interface = Interface()
    
    func test_generatePrivateKey() {
        interface.privateKey = Interface.generatePrivateKey()
        XCTAssertEqual(interface.privateKey?.count, 44)
        XCTAssertFalse(interface.privateKey?.isEmpty ?? true)
    }
    
    func test_publicKey() {
        interface.privateKey = "+CRaGBKzRDMBCrkP6ETC8CzzASl97v1oZtMcfo/9pFg="
        XCTAssertEqual(interface.publicKey, "zIbn7AoBFkQg6uKvw3RupKUTK5H1cnJFeaZTXdyh8Fc=")
    }
    
    func test_initWithDictionary() {
        let interface = Interface(["ip_address": "10.0.0.1"])
        XCTAssertEqual(interface?.addresses, "10.0.0.1")
    }
    
}
