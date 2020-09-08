//
//  ProofsViewModelTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-06-30.
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
