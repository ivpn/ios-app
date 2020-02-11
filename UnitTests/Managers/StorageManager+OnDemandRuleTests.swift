//
//  UnitTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 02/01/2019.
//  Copyright © 2018 IVPN. All rights reserved.
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
    
    func testGetDefaultTrust() {
        StorageManager.saveDefaultNetwork()
        XCTAssertEqual(StorageManager.getDefaultTrust(), NetworkTrust.None.rawValue)
    }
    
    func testTrustValue() {
        XCTAssertEqual(StorageManager.trustValue(trust: NetworkTrust.Default.rawValue, defaultTrust: NetworkTrust.Untrusted.rawValue), NetworkTrust.Untrusted.rawValue)
        XCTAssertEqual(StorageManager.trustValue(trust: NetworkTrust.Trusted.rawValue, defaultTrust: NetworkTrust.Untrusted.rawValue), NetworkTrust.Trusted.rawValue)
    }
    
    func testGetOnDemandRules() {
        StorageManager.clearSession()
        
        var rules = StorageManager.getOnDemandRules(status: .disconnected)
        XCTAssertEqual(rules[0].interfaceTypeMatch, .any)
        
        rules = StorageManager.getOnDemandRules(status: .connected)
        XCTAssertEqual(rules[0].interfaceTypeMatch, .any)
        
        StorageManager.clearSession()
    }
    
    func testGetWiFiOnDemandRules() {
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.networkProtectionEnabled)
        
        StorageManager.remove(entityName: "Network")
        StorageManager.saveDefaultNetwork()
        defaultNetwork?.trust = NetworkTrust.Untrusted.rawValue
        
        StorageManager.saveNetwork(name: "WiFi 1", type: NetworkType.wifi.rawValue, trust: NetworkTrust.Default.rawValue)
        StorageManager.saveNetwork(name: "WiFi 2", type: NetworkType.wifi.rawValue, trust: NetworkTrust.Untrusted.rawValue)
        
        let rules = StorageManager.getOnDemandRules(status: .disconnected)
        XCTAssertEqual(rules[0].interfaceTypeMatch, .wiFi)
        XCTAssertEqual(rules[0].ssidMatch?.count, 2)
        XCTAssertEqual(rules[0].ssidMatch?[0], "WiFi 1")
        XCTAssertEqual(rules[0].ssidMatch?[1], "WiFi 2")
        
        defaultNetwork?.trust = NetworkTrust.None.rawValue
    }

}
