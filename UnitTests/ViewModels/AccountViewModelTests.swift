//
//  AccountViewModelTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 24/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class AccountViewModelTests: XCTestCase {
    
    func testStatusText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.statusText, "INACTIVE")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.statusText, "ACTIVE")
    }
    
    func testSubscriptionText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        viewModel.serviceStatus.currentPlan = "IVPN Standard"
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.subscriptionText, "No active subscription")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.subscriptionText, "IVPN Standard")
    }
    
    func testLogOutActionText() {
        let viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        XCTAssertEqual(viewModel.logOutActionText, "Log In or Sign Up")
    }
    
    func testSubscriptionActionText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.subscriptionActionText, "Activate Subscription")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.subscriptionActionText, "Manage Subscription")
    }
    
    func testShowSubscriptionAction() {
        let viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        XCTAssertFalse(viewModel.showSubscriptionAction)
    }
    
}
