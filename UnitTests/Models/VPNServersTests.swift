//
//  VPNServersTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 06/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import XCTest
import CoreData

@testable import IVPNClient

class VPNServersTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        VPNServerList.removeCached()
    }
    
    override func tearDown() {
        VPNServerList.removeCached()
        
        super.tearDown()
    }
    
    func test_initWithDefaults() {
        let servers = VPNServerList()
        let server = servers.getServer(byGateway: "de.gw.ivpn.net")
        
        XCTAssertNotNil(servers)
        XCTAssert(servers.servers.count > 5)
        
        XCTAssertNotNil(server)
        XCTAssert(server!.countryCode == "DE")
        XCTAssert(server!.country == "Germany")
        XCTAssert(server!.city == "Frankfurt")
        XCTAssert(server!.ipAddresses.count > 0)
    }
    
    func test_updateWithNewData() {
        var servers = VPNServerList()
        
        XCTAssertNotNil(servers)
        XCTAssert(servers.servers.count > 10)
        
        if let newServersData = FileSystemManager.loadDataFromResource(
            resourceName: "test_servers",
            resourceType: "json",
            bundle: Bundle(for: type(of: self))
            ) {
            servers = VPNServerList(withJSONData: newServersData, storeInCache: true)
            XCTAssertNotNil(servers)
            XCTAssert(servers.servers.count == 2)
            
            servers = VPNServerList()
            XCTAssertNotNil(servers)
            XCTAssert(servers.servers.count == 2)
            
            // Remove the cached version
            VPNServerList.removeCached()
            
            servers = VPNServerList()
            XCTAssertNotNil(servers)
            XCTAssert(servers.servers.count > 10)
        }
    }
    
    func test_updateMultipleTimes() {
        let newServersData = FileSystemManager.loadDataFromResource(
            resourceName: "test_servers",
            resourceType: "json",
            bundle: Bundle(for: type(of: self))
        )
        
        if let newServersData = newServersData {
            let _ = VPNServerList(withJSONData: newServersData, storeInCache: true)
            
            if let newServersData = FileSystemManager.loadDataFromResource(
                resourceName: "servers",
                resourceType: "json"
                ) {
                let _ = VPNServerList(withJSONData: newServersData, storeInCache: true)
                
                let servers = VPNServerList()
                XCTAssertNotNil(servers)
                XCTAssert(servers.servers.count > 10)
            }
        }
    }
    
}
