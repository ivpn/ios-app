//
//  AppKeyManagerTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-03-26.
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

class AppKeyManagerTests: XCTestCase {
    
    func test_keyExpirationTimestamp() {
        UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
        
        let keyExpirationTimestamp = AppKeyManager.keyExpirationTimestamp
        
        XCTAssertTrue(keyExpirationTimestamp > Date())
        XCTAssertTrue(keyExpirationTimestamp > Date.changeDays(by: Config.wgKeyExpirationDays - 1))
        XCTAssertTrue(keyExpirationTimestamp < Date.changeDays(by: Config.wgKeyExpirationDays + 1))
    }
    
    func test_keyRegenerationTimestamp() {
        UserDefaults.shared.set(Config.wgKeyRegenerationRate, forKey: UserDefaults.Key.wgRegenerationRate)
        
        let keyRegenerationTimestamp = AppKeyManager.keyRegenerationTimestamp
        let wgRegenerationRate = UserDefaults.shared.wgRegenerationRate
        
        XCTAssertTrue(keyRegenerationTimestamp > Date())
        XCTAssertTrue(keyRegenerationTimestamp > Date.changeDays(by: wgRegenerationRate - 1))
        XCTAssertTrue(keyRegenerationTimestamp < Date.changeDays(by: wgRegenerationRate + 1))
    }
    
    func test_isKeyExpired() {
        XCTAssertFalse(AppKeyManager.isKeyExpired)
        
        UserDefaults.shared.set(Date.changeDays(by: (-10 - Config.wgKeyExpirationDays)), forKey: UserDefaults.Key.wgKeyTimestamp)
        KeyChain.wgPublicKey = "5q5ijOijHkhkJWiWT3bC7jRGFfDQo+2EL5aCgGgW5Qw="
        
        XCTAssertTrue(AppKeyManager.isKeyExpired)
    }
    
    func test_generateKeyPair() {
        AppKeyManager.generateKeyPair()
        XCTAssertTrue(KeyChain.wgPrivateKey != nil)
        XCTAssertTrue(KeyChain.wgPublicKey != nil)
    }
    
    func test_regenerationInterval() {
        UserDefaults.shared.set(Config.wgKeyRegenerationRate, forKey: UserDefaults.Key.wgRegenerationRate)
        let regenerationCheckInterval = AppKeyManager.regenerationCheckInterval
        let regenerationInterval = AppKeyManager.regenerationInterval
        XCTAssertTrue(regenerationInterval > regenerationCheckInterval)
    }
    
}
