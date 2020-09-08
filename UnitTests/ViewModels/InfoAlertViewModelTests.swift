//
//  InfoAlertViewModelTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-16.
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

class InfoAlertViewModelTests: XCTestCase {
    
    let viewModel = InfoAlertViewModel()
    
    func test_text() {
        viewModel.infoAlert = .subscriptionExpiration
        XCTAssertTrue(viewModel.text.starts(with: "Subscription will expire") || viewModel.text.starts(with: "Subscription expired"))
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
