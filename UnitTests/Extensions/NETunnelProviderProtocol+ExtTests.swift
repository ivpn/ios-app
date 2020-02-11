//
//  NETunnelProviderProtocol+ExtTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 22/07/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest
import NetworkExtension

@testable import IVPNClient

class NETunnelProviderProtocolExtTests: XCTestCase {
    
    let antiTrackerDNS = "10.0.254.2"
    let antiTrackerDNSMultiHop = "10.0.254.102"
    let antiTrackerHardcoreDNS = "10.0.254.3"
    let antiTrackerHardcoreDNSMultiHop = "10.0.254.103"
    let customDNS = "1.1.1.1"
    
    override func setUp() {
        UserDefaults.shared.set(antiTrackerDNS, forKey: UserDefaults.Key.antiTrackerDNS)
        UserDefaults.shared.set(antiTrackerDNSMultiHop, forKey: UserDefaults.Key.antiTrackerDNSMultiHop)
        UserDefaults.shared.set(antiTrackerHardcoreDNS, forKey: UserDefaults.Key.antiTrackerHardcoreDNS)
        UserDefaults.shared.set(antiTrackerHardcoreDNSMultiHop, forKey: UserDefaults.Key.antiTrackerHardcoreDNSMultiHop)
        UserDefaults.shared.set(customDNS, forKey: UserDefaults.Key.customDNS)
        
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
    }
    
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.antiTrackerDNS)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.antiTrackerDNSMultiHop)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.antiTrackerHardcoreDNS)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.antiTrackerHardcoreDNSMultiHop)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Key.customDNS)
        
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTracker)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isMultiHop)
    }
    
    func testOpenVPNdnsServers() {
        XCTAssertNil(NETunnelProviderProtocol.openVPNdnsServers())
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isCustomDNS)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [customDNS])
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isAntiTracker)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [antiTrackerDNS])
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [antiTrackerHardcoreDNS])
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isMultiHop)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [antiTrackerDNSMultiHop])
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isAntiTrackerHardcore)
        XCTAssertEqual(NETunnelProviderProtocol.openVPNdnsServers(), [antiTrackerHardcoreDNSMultiHop])
    }
    
}
