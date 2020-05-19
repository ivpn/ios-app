//
//  XCUIApplication+Ext.swift
//  UITests
//
//  Created by Juraj Hilje on 22/10/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

extension XCUIApplication {
    
    var isDisplayingTermsOfServiceScreen: Bool {
        return otherElements["termsOfServiceScreen"].exists
    }
    
    var isDisplayingLoginScreen: Bool {
        return otherElements["loginScreen"].exists
    }
    
    var isDisplayingSubscriptionScreen: Bool {
        return otherElements["subscriptionScreen"].exists
    }
    
    var isDisplayingMainScreen: Bool {
        return otherElements["mainScreen"].exists
    }
    
    var isDisplayingSettingsScreen: Bool {
        return otherElements["settingsScreen"].exists
    }
    
}
