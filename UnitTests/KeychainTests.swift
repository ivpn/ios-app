//
//  KeyChainTests.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/9/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import XCTest
import KeychainAccess

@testable import IVPNClient

class KeychainTests: XCTestCase {
    
    let testKey = "ivpn.username"
    let testValue = "Test string input"
    
    override func setUp() {
        super.setUp()
        
        let keychain = Keychain()
        keychain[testKey] = nil
    }
    
    override func tearDown() {
        let keychain = Keychain()
        keychain[testKey] = nil

        super.tearDown()
    }
    
    func testAddRemoveStringValue() {
        let keychain = Keychain()
        
        // Ensure that no data is present in the keychain before test
        var value = keychain[testKey]
        XCTAssert(value == nil)
        
        // Save some string into KeyChain
        keychain[string: testKey] = testValue
        
        // Retrieve stored string
        value = keychain[testKey]
        XCTAssert(value == testValue)

        // Retrieve the persistent ref for the value
        let data = keychain[attributes: testKey]?.persistentRef
        XCTAssert(data != nil)
        
        // Remove the strored string
        keychain[testKey] = nil
        
        // Ensure that string was successfully remove from the keyChain
        value = keychain[testKey]
        XCTAssert(value == nil)
    }
    
}
