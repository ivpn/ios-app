//
//  AppKeyManagerTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 26/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class AppKeyManagerTests: XCTestCase {
    
    func testKeyExpirationTimestamp() {
        UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
        
        let keyExpirationTimestamp = AppKeyManager.keyExpirationTimestamp
        
        XCTAssertTrue(keyExpirationTimestamp > Date())
        XCTAssertTrue(keyExpirationTimestamp > Date.changeDays(by: Config.wgKeyExpirationDays - 1))
        XCTAssertTrue(keyExpirationTimestamp < Date.changeDays(by: Config.wgKeyExpirationDays + 1))
    }
    
    func testKeyRegenerationTimestamp() {
        UserDefaults.shared.set(Config.wgKeyRegenerationRate, forKey: UserDefaults.Key.wgRegenerationRate)
        
        let keyRegenerationTimestamp = AppKeyManager.keyRegenerationTimestamp
        let wgRegenerationRate = UserDefaults.shared.wgRegenerationRate
        
        XCTAssertTrue(keyRegenerationTimestamp > Date())
        XCTAssertTrue(keyRegenerationTimestamp > Date.changeDays(by: wgRegenerationRate - 1))
        XCTAssertTrue(keyRegenerationTimestamp < Date.changeDays(by: wgRegenerationRate + 1))
    }
    
    func testIsKeyExpired() {
        XCTAssertFalse(AppKeyManager.isKeyExpired)
        
        UserDefaults.shared.set(Date.changeDays(by: (-10 - Config.wgKeyExpirationDays)), forKey: UserDefaults.Key.wgKeyTimestamp)
        KeyChain.wgPublicKey = "5q5ijOijHkhkJWiWT3bC7jRGFfDQo+2EL5aCgGgW5Qw="
        
        XCTAssertTrue(AppKeyManager.isKeyExpired)
    }
    
    func testGenerateKeyPair() {
        AppKeyManager.generateKeyPair()
        XCTAssertTrue(KeyChain.wgPrivateKey != nil)
        XCTAssertTrue(KeyChain.wgPublicKey != nil)
    }
    
}
