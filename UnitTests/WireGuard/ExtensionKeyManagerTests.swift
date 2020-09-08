//
//  ExtensionKeyManagerTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-03-27.
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
