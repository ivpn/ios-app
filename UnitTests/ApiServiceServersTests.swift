//
//  ApiServiceServers.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/16/16.
//  Copyright © 2016 IVPN. All rights reserved.
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
    
    func testUpdateServers() {
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
