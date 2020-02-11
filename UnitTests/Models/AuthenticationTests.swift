//
//  AuthenticationTests.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/9/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class AuthenticationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        KeyChain.clearAll()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
