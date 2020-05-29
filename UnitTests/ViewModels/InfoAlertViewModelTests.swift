//
//  InfoAlertViewModelTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 16/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class InfoAlertViewModelTests: XCTestCase {
    
    let viewModel = InfoAlertViewModel()
    
    func testText() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertTrue(viewModel.text.starts(with: "Subscription will expire"))
    }
    
    func testActionText() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertEqual(viewModel.actionText, "RENEW")
    }
    
    func testType() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertEqual(viewModel.type, .alert)
    }
    
}
