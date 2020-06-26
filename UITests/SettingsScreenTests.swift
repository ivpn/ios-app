//
//  SettingsScreenTests.swift
//  UITests
//
//  Created by Juraj Hilje on 23/10/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

class SettingsScreenTests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        app.launch()
    }
    
    func testSettingsToLoginPath() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Open Settings"].tap()
        app.tables["settingsScreen"].swipeUp()
        app.buttons["Log In or Sign Up"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
        
        app.buttons["Log In"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Agree"].tap()
        let loginScreen = app.otherElements["loginScreen"].waitForExistence(timeout: 1)
        XCTAssert(loginScreen)
    }
    
    func testSelectProtocol() {
        let app = XCUIApplication()

        XCTAssertTrue(app.isDisplayingMainScreen)

        app.buttons["Open Settings"].tap()
        app.tables["settingsScreen"].staticTexts["IKEv2"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
    }
    
    func testNetworkProtection() {
        let app = XCUIApplication()

        XCTAssertTrue(app.isDisplayingMainScreen)

        app.buttons["Open Settings"].tap()
        app.tables["settingsScreen"].staticTexts["Network Protection"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
    }
    
}
