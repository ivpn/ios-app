//
//  StorageManagerOnDemandRuleTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-01-02.
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
import CoreData
import NetworkExtension

@testable import IVPNClient

class StorageManagerOnDemandRuleTests: XCTestCase {
    
    var defaultNetwork: Network? {
        if let defaultNetworks = StorageManager.fetchNetworks(isDefault: true) {
            if let first = defaultNetworks.first {
                return first
            }
        }
        return nil
    }
    
    func test_getDefaultTrust() {
        StorageManager.saveDefaultNetwork()
        XCTAssertEqual(StorageManager.getDefaultTrust(), NetworkTrust.None.rawValue)
    }
    
    func test_trustValue() {
        XCTAssertEqual(StorageManager.trustValue(trust: NetworkTrust.Default.rawValue, defaultTrust: NetworkTrust.Untrusted.rawValue), NetworkTrust.Untrusted.rawValue)
        XCTAssertEqual(StorageManager.trustValue(trust: NetworkTrust.Trusted.rawValue, defaultTrust: NetworkTrust.Untrusted.rawValue), NetworkTrust.Trusted.rawValue)
    }
    
    func test_getOnDemandRules() {
        StorageManager.clearSession()
        
        var rules = StorageManager.getOnDemandRules(status: .disconnected)
        XCTAssertEqual(rules[0].interfaceTypeMatch, .any)
        
        rules = StorageManager.getOnDemandRules(status: .connected)
        XCTAssertEqual(rules[0].interfaceTypeMatch, .any)
        
        StorageManager.clearSession()
    }
    
    func test_getWiFiOnDemandRules() {
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.networkProtectionEnabled)
        
        StorageManager.remove(entityName: "Network")
        StorageManager.saveDefaultNetwork()
        defaultNetwork?.trust = NetworkTrust.Untrusted.rawValue
        
        StorageManager.saveNetwork(name: "Wi-Fi 1", type: NetworkType.wifi.rawValue, trust: NetworkTrust.Default.rawValue)
        StorageManager.saveNetwork(name: "Wi-Fi 2", type: NetworkType.wifi.rawValue, trust: NetworkTrust.Untrusted.rawValue)
        
        let rules = StorageManager.getOnDemandRules(status: .disconnected)
        XCTAssertEqual(rules[0].interfaceTypeMatch, .wiFi)
        XCTAssertEqual(rules[0].ssidMatch?.count, 2)
        XCTAssertEqual(rules[0].ssidMatch?[0], "Wi-Fi 1")
        XCTAssertEqual(rules[0].ssidMatch?[1], "Wi-Fi 2")
        
        defaultNetwork?.trust = NetworkTrust.None.rawValue
    }

}
