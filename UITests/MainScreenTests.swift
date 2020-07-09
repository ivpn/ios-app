//
//  MainScreenTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-10-22.
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

class MainScreenTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }
    
    func test_tapConnectButtonToLoginPath() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        app.launch()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Vienna"].tap()
        app.otherElements.buttons["CONNECT TO SERVER"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
        
        app.buttons["Create Account"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Decline"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
        
        app.buttons["Log In"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
    }
    
    func test_tapConnectButtonToSubscribe() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITests", "-authenticated"]
        app.launch()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Vienna"].tap()
        app.otherElements.buttons["CONNECT TO SERVER"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.isDisplayingMainScreen)
    }
    
    func test_tapConnectButton() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITests", "-authenticated", "-activeService", "-hasUserConsent"]
        app.launch()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Vienna"].tap()
        app.otherElements.buttons["CONNECT TO SERVER"].tap()
        XCTAssertFalse(app.isDisplayingTermsOfServiceScreen)
        XCTAssertFalse(app.isDisplayingLoginScreen)
        XCTAssertFalse(app.isDisplayingSubscriptionScreen)
        XCTAssertTrue(app.isDisplayingMainScreen)
    }

}
