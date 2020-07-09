//
//  UserDefaultsTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-02-11.
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

class UserDefaultsTests: XCTestCase {
    
    func test_properties() {
        XCTAssertNotNil(UserDefaults.shared.wireguardTunnelProviderError)
        XCTAssertNotNil(UserDefaults.shared.isMultiHop)
        XCTAssertNotNil(UserDefaults.shared.exitServerLocation)
        XCTAssertNotNil(UserDefaults.shared.isLogging)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionEnabled)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionUntrustedConnect)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionTrustedDisconnect)
        XCTAssertNotNil(UserDefaults.shared.isCustomDNS)
        XCTAssertNotNil(UserDefaults.shared.customDNS)
        XCTAssertNotNil(UserDefaults.shared.isAntiTracker)
        XCTAssertNotNil(UserDefaults.shared.isAntiTrackerHardcore)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerDNS)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerDNSMultiHop)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerHardcoreDNS)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerHardcoreDNSMultiHop)
        XCTAssertNotNil(UserDefaults.shared.wgKeyTimestamp)
        XCTAssertNotNil(UserDefaults.shared.wgRegenerationRate)
        XCTAssertNotNil(UserDefaults.shared.localIpAddress)
        XCTAssertNotNil(UserDefaults.shared.serversSort)
    }
    
}
