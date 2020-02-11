//
//  APIAccessManagerTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 20/08/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class APIAccessManagerTests: XCTestCase {
    
    override func setUp() {
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.apiHostName)
        UserDefaults.shared.set(["1.1.1.1"], forKey: UserDefaults.Key.hostNames)
    }
    
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.hostNames)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.apiHostName)
    }
    
    func testIsHostIpAddress() {
        XCTAssertTrue(APIAccessManager.shared.isHostIpAddress(host: "1.1.1.1"))
        XCTAssertFalse(APIAccessManager.shared.isHostIpAddress(host: "ivpn.net"))
    }
    
    func testNextHostName() {
        let currentHost = UserDefaults.shared.apiHostName
        if let nextHost = APIAccessManager.shared.nextHostName(failedHostName: currentHost) {
            XCTAssertEqual(nextHost, "1.1.1.1")
        } else {
            XCTFail("Hostname not found")
        }
    }
    
}
