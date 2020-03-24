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
    
    var serviceStatus = ServiceStatus()
    var authentication = Authentication()
    
    func testStatusText() {
        var viewModel = AccountViewModel(serviceStatus: serviceStatus, authentication: authentication)
        
        viewModel.serviceStatus.isActive = false
        XCTAssertEqual(viewModel.statusText, "INACTIVE")
        
        viewModel.serviceStatus.isActive = true
        XCTAssertEqual(viewModel.statusText, "ACTIVE")
    }
    
}
