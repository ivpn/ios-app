//
//  InitScreenTests.swift
//  UITests
//
//  Created by Juraj Hilje on 22/10/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

class InitScreenTests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        app.launch()
    }
    
    func test_tapLogInButton() {
        let app = XCUIApplication()

        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Vienna"].tap()
        app.otherElements.buttons["CONNECT TO SERVER"].tap()
        app.buttons["Log In"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
    }
    
    func test_tapSignUpButton() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.isDisplayingMainScreen)
        
        app.buttons["Vienna"].tap()
        app.otherElements.buttons["CONNECT TO SERVER"].tap()
        app.buttons["Create Account"].tap()
        XCTAssertTrue(app.isDisplayingTermsOfServiceScreen)
    }

}
