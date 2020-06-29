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
    
    func test_statusText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.statusText, "INACTIVE")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.statusText, "ACTIVE")
    }
    
    func test_subscriptionText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        viewModel.serviceStatus.currentPlan = "IVPN Standard"
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.subscriptionText, "IVPN Standard")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.subscriptionText, "IVPN Standard")
    }
    
    func test_activeUntilText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.activeUntilText, "No active subscription")
    }
    
    func test_logOutActionText() {
        let viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        XCTAssertEqual(viewModel.logOutActionText, "Log In or Sign Up")
    }
    
    func test_subscriptionActionText() {
        var viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.subscriptionActionText, "Activate Subscription")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.subscriptionActionText, "Manage Subscription")
    }
    
    func test_showSubscriptionAction() {
        let viewModel = AccountViewModel(serviceStatus: ServiceStatus(), authentication: Authentication())
        XCTAssertFalse(viewModel.showSubscriptionAction)
    }
    
}
