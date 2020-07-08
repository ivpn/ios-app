//
//  ApiServiceServers.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-16.
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

class ApiServiceServersTests: XCTestCase {
    
    override func setUp() {        
        super.setUp()
        VPNServerList.removeCached()
    }
    
    override func tearDown() {
        VPNServerList.removeCached()
        super.tearDown()
    }
    
    // This test both tests that the new servers list is retrieved from the server
    // as well as it is stored in the cache
    
    func test_updateServers() {
        VPNServerList.removeCached()
        let testBundle = Bundle(for: type(of: self))
        let serviceApi = ApiService.shared
        var serversUpdateResult: ServersUpdateResult?
        let asyncExpectation = expectation(description: "login Expectation")
        let _ = serviceApi.getServersList(storeInCache: true) { updateResult in
            serversUpdateResult = updateResult
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: ApiSettings.maxTimeoutForExpectationSec)
     
        XCTAssert(serversUpdateResult != nil)
        
        switch serversUpdateResult! {
        case .error:
            XCTFail("Servers update failed")
        case .success(let serverList):
            XCTAssertFalse(serverList.servers.isEmpty)
            
            // Test that the servers list is stored in the cache
            // and that the next query will return the updated
            // servers list
            
            let defaultServerList = VPNServerList(
                bundleForDefaultResource: testBundle)
                        
            XCTAssertFalse(defaultServerList.servers.isEmpty)
        }
    }
    
}
