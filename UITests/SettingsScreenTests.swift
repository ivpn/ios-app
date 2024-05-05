//
//  SettingsScreenTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-10-23.
//  Copyright (c) 2023 IVPN Limited.
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

class SettingsScreenTests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        app.launch()
    }
    
    func test_settingsToLoginPath() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Account"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
        
        app.buttons["Log In"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Cancel"].tap()
        let loginScreen = app.otherElements["loginScreen"].waitForExistence(timeout: 1)
        XCTAssert(loginScreen)
    }
    
    func test_selectProtocol() {
        let app = XCUIApplication()

        XCTAssertTrue(app.isDisplayingMainScreen)

        app.buttons["Settings"].tap()
        app.tables["settingsScreen"].staticTexts["WireGuard, UDP 2049"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
    }
    
    func test_networkProtection() {
        let app = XCUIApplication()

        XCTAssertTrue(app.isDisplayingMainScreen)

        app.buttons["Settings"].tap()
        app.tables["settingsScreen"].staticTexts["Network Protection"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
    }
    
}
