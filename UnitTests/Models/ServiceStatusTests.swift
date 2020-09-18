//
//  ServiceStatusTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-01-10.
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
    
    func test_activeUntilString() {
        XCTAssertEqual(model.activeUntilString(), "2020-Jan-10")
    }
    
    func test_isEnabled() {
        XCTAssertFalse(model.isEnabled(capability: .multihop))
        XCTAssertFalse(model.isEnabled(capability: .portForwarding))
        XCTAssertFalse(model.isEnabled(capability: .wireguard))
        XCTAssertFalse(model.isEnabled(capability: .privateEmails))
    }
    
    func test_getSubscriptionText() {
        XCTAssertEqual(model.getSubscriptionText(), "No active subscription")
        
        model.isActive = true
        XCTAssertEqual(model.getSubscriptionText(), "Active until \(model.activeUntilString())")
        
        model.currentPlan = "IVPN Pro"
        XCTAssertEqual(model.getSubscriptionText(), "\(model.currentPlan ?? ""), Active until \(model.activeUntilString())")
    }
    
    func test_isValid() {
        XCTAssertTrue(ServiceStatus.isValid(username: "ivpnXXXXXXXX"))
        XCTAssertTrue(ServiceStatus.isValid(username: "i-XXXX-XXXX-XXXX"))
        XCTAssertFalse(ServiceStatus.isValid(username: "IVPNXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isValid(username: "XXXXXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isValid(username: ""))
    }
    
    func test_daysUntilSubscriptionExpiration() {
        model.activeUntil = Int(Date().changeDays(by: 3).timeIntervalSince1970)
        XCTAssertEqual(model.daysUntilSubscriptionExpiration(), 3)
        
        model.activeUntil = Int(Date().changeDays(by: 0).timeIntervalSince1970)
        XCTAssertEqual(model.daysUntilSubscriptionExpiration(), 0)
        
        model.activeUntil = Int(Date().changeDays(by: -3).timeIntervalSince1970)
        XCTAssertEqual(model.daysUntilSubscriptionExpiration(), 0)
    }
    
    func test_isNewStyleAccount() {
        XCTAssertTrue(ServiceStatus.isNewStyleAccount(username: "i-XXXX-XXXX-XXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: "ivpnXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: "IVPNXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: "XXXXXXXXXXXX"))
        XCTAssertFalse(ServiceStatus.isNewStyleAccount(username: ""))
    }
    
    func test_isActiveUntilValid() {
        model.activeUntil = nil
        XCTAssertFalse(model.isActiveUntilValid())
        model.activeUntil = 0
        XCTAssertFalse(model.isActiveUntilValid())
        model.activeUntil = 1578643221
        XCTAssertTrue(model.isActiveUntilValid())
    }
    
}
