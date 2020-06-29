//
//  ExtensionKeyManagerTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 27/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class ExtensionKeyManagerTests: XCTestCase {
    
    func test_regenerationInterval() {
        UserDefaults.shared.set(Config.wgKeyRegenerationRate, forKey: UserDefaults.Key.wgRegenerationRate)
        let regenerationCheckInterval = ExtensionKeyManager.regenerationCheckInterval
        let regenerationInterval = ExtensionKeyManager.regenerationInterval
        XCTAssertTrue(regenerationInterval > regenerationCheckInterval)
    }
    
    func test_needToRegenerate() {
        UserDefaults.shared.set(Date.changeDays(by: -50), forKey: UserDefaults.Key.wgKeyTimestamp)
        KeyChain.wgPublicKey = nil
        XCTAssertFalse(ExtensionKeyManager.needToRegenerate())
        
        KeyChain.wgPublicKey = "5q5ijOijHkhkJWiWT3bC7jRGFfDQo+2EL5aCgGgW5Qw="
        XCTAssertTrue(ExtensionKeyManager.needToRegenerate())
        
        UserDefaults.shared.set(Date.changeDays(by: 50), forKey: UserDefaults.Key.wgKeyTimestamp)
        XCTAssertFalse(ExtensionKeyManager.needToRegenerate())
    }

}
