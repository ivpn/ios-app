//
//  NETunnelProviderProtocol+ExtTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-07-22.
//  Copyright (c) 2023 IVPN Limited.
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
import NetworkExtension

@testable import IVPNClient

class NETunnelProviderProtocolExtTests: XCTestCase {
    
    let antiTrackerDNS = "10.0.254.2"
    let antiTrackerHardcoreDNS = "10.0.254.3"
    let customDNS = "1.1.1.1"
    
    override func setUp() {
        UserDefaults.shared.set(antiTrackerDNS, forKey: UserDefaults.Key.antiTrackerDNS)
        UserDefaults.shared.set(antiTrackerHardcoreDNS, forKey: UserDefaults.Key.antiTrackerHardcoreDNS)
        UserDefaults.shared.set(customDNS, forKey: UserDefaults.Key.customDNS)
        
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
    }
    
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.antiTrackerDNS)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.antiTrackerHardcoreDNS)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.customDNS)
        
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
    }
    
    func test_openVPNdnsServers() {
        XCTAssertNil(NETunnelProviderProtocol.openVPNdnsServers())
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isCustomDNS)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [customDNS])
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isAntiTracker)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [antiTrackerDNS])
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [antiTrackerHardcoreDNS])
    }
    
}
