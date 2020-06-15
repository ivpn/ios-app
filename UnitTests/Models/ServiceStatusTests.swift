//
//  ServiceStatusTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 10/01/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class ServiceStatusTests: XCTestCase {
    
    var model = ServiceStatus()
    
    override func setUp() {
        model.activeUntil = 1578643221
        model.isActive = false
        model.currentPlan = nil
    }
    
    override func tearDown() {
        model.isActive = false
        model.currentPlan = nil
    }
    
    func testActiveUntilString() {
        XCTAssertEqual(model.activeUntilString(), "Jan 10, 2020")
    }
    
    func testIsEnabled() {
        XCTAssertFalse(model.isEnabled(capability: .multihop))
        XCTAssertFalse(model.isEnabled(capability: .portForwarding))
        XCTAssertFalse(model.isEnabled(capability: .wireguard))
        XCTAssertFalse(model.isEnabled(capability: .privateEmails))
    }
    
    func testGetSubscriptionText() {
        XCTAssertEqual(model.getSubscriptionText(), "No active subscription")
        
        model.isActive = true
        XCTAssertEqual(model.getSubscriptionText(), "Active until \(model.activeUntilString())")
        
        model.currentPlan = "IVPN Pro"
        XCTAssertEqual(model.getSubscriptionText(), "\(model.currentPlan ?? ""), Active until \(model.activeUntilString())")
    }
    
    func testIsValid() {
        XCTAssertTrue(ServiceStatus.isValid(username: "ivpnXXXXXXXX"))
        XCTAssertTrue(ServiceStatus.isValid(username: "i-XXXX-XXXX-XXXX"))
        XCTAssertFalse(ServiceStatus.isValid(username: "IVPNXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isValid(username: "XXXXXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isValid(username: ""))
    }
    
    func testDaysUntilSubscriptionExpiration() {
        XCTAssertEqual(model.daysUntilSubscriptionExpiration(), 0)
    }
    
    func test_isNewStyleAccount() {
        XCTAssertTrue(ServiceStatus.isNewStyleAccount(username: "i-XXXX-XXXX-XXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: "ivpnXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: "IVPNXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: "XXXXXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: ""))
    }
    
}
