//
//  MainScreenTests.swift
//  UITests
//
//  Created by Juraj Hilje on 22/10/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

class MainScreenTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }
    
    func testTapConnectButtonToLoginPath() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        app.launch()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Tap to connect"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
        
        app.buttons["Create Account"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Decline"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
        
        app.buttons["Log In"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Agree"].tap()
        XCTAssertTrue(app.isDisplayingLoginScreen)
    }
    
    func testTapConnectButtonToSubscribe() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITests", "-authenticated"]
        app.launch()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Tap to connect"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
        
        app.buttons["Agree"].tap()
        app.buttons["Close"].tap()
        XCTAssertTrue(app.isDisplayingMainScreen)
    }
    
    func testTapConnectButton() {
        let app = XCUIApplication()
        app.launchArguments = ["-UITests", "-authenticated", "-activeService", "-hasUserConsent"]
        app.launch()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Tap to connect"].tap()
        XCTAssertFalse(app.isDisplayingTermsOfServiceScreen)
        XCTAssertFalse(app.isDisplayingLoginScreen)
        XCTAssertFalse(app.isDisplayingSubscriptionScreen)
        XCTAssertTrue(app.isDisplayingMainScreen)
    }

}
