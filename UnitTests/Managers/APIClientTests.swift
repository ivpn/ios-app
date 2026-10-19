//
//  APIClientTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2026-08-17.
//  Copyright (c) 2023 IVPN Limited.
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

class APIClientTests: XCTestCase {
    
    let apiClient = APIClient()
    let hostName = "api.ivpn.net"
    
    func test_postRequestWithParams_hasNoTrailingQuestionMark() {
        let request = APIRequest(method: .post, path: "/v4/session/wg/set")
        request.queryItems = [URLQueryItem(name: "session_token", value: "abc")]
        
        let url = apiClient.buildRequestURL(for: request, hostName: hostName)
        
        XCTAssertEqual(url?.absoluteString, "https://\(hostName)/v4/session/wg/set")
    }
    
    func test_getRequestWithNilParams_hasNoTrailingQuestionMark() {
        let request = APIRequest(method: .get, path: "/v4/session/wg/set")
        request.queryItems = nil
        
        let url = apiClient.buildRequestURL(for: request, hostName: hostName)
        
        XCTAssertEqual(url?.absoluteString, "https://\(hostName)/v4/session/wg/set")
    }
    
    func test_getRequestWithEmptyParams_hasNoTrailingQuestionMark() {
        let request = APIRequest(method: .get, path: "/v4/session/wg/set")
        request.queryItems = []
        
        let url = apiClient.buildRequestURL(for: request, hostName: hostName)
        
        XCTAssertEqual(url?.absoluteString, "https://\(hostName)/v4/session/wg/set")
    }
    
    func test_getRequestWithParams_includesQueryString() {
        let request = APIRequest(method: .get, path: "/v4/session/wg/set")
        request.queryItems = [URLQueryItem(name: "session_token", value: "abc")]
        
        let url = apiClient.buildRequestURL(for: request, hostName: hostName)
        
        XCTAssertEqual(url?.absoluteString, "https://\(hostName)/v4/session/wg/set?session_token=abc")
    }
    
}
