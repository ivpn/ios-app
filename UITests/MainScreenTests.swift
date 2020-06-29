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
