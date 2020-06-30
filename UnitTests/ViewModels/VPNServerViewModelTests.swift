//
//  VPNServerViewModelTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 30/06/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class VPNServerViewModelTests: XCTestCase {
    
    var viewModel = VPNServerViewModel(server: VPNServer(gateway: "nl.wg.ivpn.net", countryCode: "NL", country: "Netherlands", city: "Amsterdam"))
    
    func test_imageNameForPingTime() {
        viewModel.server.pingMs = nil
        XCTAssertEqual(viewModel.imageNameForPingTime, "")
        
        viewModel.server.pingMs = 50
        XCTAssertEqual(viewModel.imageNameForPingTime, "icon-circle-green")
        
        viewModel.server.pingMs = 200
        XCTAssertEqual(viewModel.imageNameForPingTime, "icon-circle-orange")
        
        viewModel.server.pingMs = 400
        XCTAssertEqual(viewModel.imageNameForPingTime, "icon-circle-red")
    }
    
    func test_formattedServerName() {
        XCTAssertEqual(viewModel.formattedServerName, "Amsterdam, NL")
    }
    
    func test_formattedServerLocation() {
        XCTAssertEqual(viewModel.formattedServerLocation, "Amsterdam, Netherlands")
    }
    
    func test_imageNameForCountryCode() {
        XCTAssertEqual(viewModel.imageNameForCountryCode, "nl-v")
    }
    
}
