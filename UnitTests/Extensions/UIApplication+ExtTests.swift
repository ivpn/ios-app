//
//  UIApplication+ExtTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 21/01/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class UIApplicationExtTests: XCTestCase {
    
    func testIsValidURL() {
        XCTAssertFalse(UIApplication.isValidURL(urlString: ""))
        XCTAssertFalse(UIApplication.isValidURL(urlString: "N.A."))
        XCTAssertTrue(UIApplication.isValidURL(urlString: "http://example.com"))
        XCTAssertTrue(UIApplication.isValidURL(urlString: "https://example.com"))
    }
    
}
