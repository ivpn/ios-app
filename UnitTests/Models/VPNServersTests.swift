//
//  VPNServersTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-02-06.
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
