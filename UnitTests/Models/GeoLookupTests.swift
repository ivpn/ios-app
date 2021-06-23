//
//  GeoLookupTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-04-14.
//  Copyright (c) 2021 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import XCTest

@testable import IVPNClient

class GeoLookupTests: XCTestCase {
    
    func test_isEqualLocation() {
        var model1 = GeoLookup(ipAddress: "", countryCode: "", country: "", city: "", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        var model2 = GeoLookup(ipAddress: "", countryCode: "", country: "", city: "", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        XCTAssertTrue(model1.isEqualLocation(to: model2))
        
        model1 = GeoLookup(ipAddress: "", countryCode: "", country: "Country 1", city: "City 1", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        model2 = GeoLookup(ipAddress: "", countryCode: "", country: "Country 1", city: "City 2", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        XCTAssertFalse(model1.isEqualLocation(to: model2))
        
        model1 = GeoLookup(ipAddress: "", countryCode: "", country: "Country 1", city: "City 1", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        model2 = GeoLookup(ipAddress: "", countryCode: "", country: "Country 2", city: "City 1", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        XCTAssertFalse(model1.isEqualLocation(to: model2))
        
        model1 = GeoLookup(ipAddress: "", countryCode: "", country: "Country 1", city: "City 1", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        model2 = GeoLookup(ipAddress: "", countryCode: "", country: "Country 1", city: "City 1", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
        XCTAssertTrue(model1.isEqualLocation(to: model2))
    }
    
}
