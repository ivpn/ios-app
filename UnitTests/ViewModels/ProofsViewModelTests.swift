//
//  ProofsViewModelTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 30/06/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class ProofsViewModelTests: XCTestCase {
    
    var viewModel = ProofsViewModel(model: GeoLookup(ipAddress: "0.0.0.0", countryCode: "DE", country: "Germany", city: "Berlin", isIvpnServer: false, isp: "ISP Provider", latitude: 0, longitude: 0))
    
    override func setUp() {
        viewModel.model = GeoLookup(ipAddress: "0.0.0.0", countryCode: "DE", country: "Germany", city: "Berlin", isIvpnServer: false, isp: "ISP Provider", latitude: 0, longitude: 0)
    }
    
    func test_imageNameForCountryCode() {
        XCTAssertEqual(viewModel.imageNameForCountryCode, "de")
    }
    
    func test_ipAddress() {
        XCTAssertEqual(viewModel.ipAddress, "0.0.0.0")
    }
    
    func test_country() {
        XCTAssertEqual(viewModel.country, "Germany")
    }
    
    func test_city() {
        XCTAssertEqual(viewModel.city, "Berlin")
    }
    
    func test_countryCode() {
        XCTAssertEqual(viewModel.countryCode, "DE")
    }
    
    func test_provider() {
        XCTAssertEqual(viewModel.provider, "ISP Provider")
        
        viewModel.model = GeoLookup(ipAddress: "0.0.0.0", countryCode: "DE", country: "Germany", city: "Berlin", isIvpnServer: true, isp: "ISP Provider", latitude: 0, longitude: 0)
        XCTAssertEqual(viewModel.provider, "IVPN")
    }
    
}
