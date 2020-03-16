//
//  InfoAlertViewModelTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 16/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class SomeTests: XCTestCase {
    
    let viewModel = InfoAlertViewModel()
    
    func testText() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertTrue(viewModel.text.starts(with: "Subscription will expire"))
        
        viewModel.infoAlert = .trialPeriod
        XCTAssertTrue(viewModel.text.starts(with: "Trial period will expire"))
    }
    
}
