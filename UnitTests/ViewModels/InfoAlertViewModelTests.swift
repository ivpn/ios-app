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
    
    func test_text() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertTrue(viewModel.text.starts(with: "Subscription will expire"))
    }
    
    func test_actionText() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertEqual(viewModel.actionText, "RENEW")
    }
    
    func test_type() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertEqual(viewModel.type, .alert)
    }
    
}
