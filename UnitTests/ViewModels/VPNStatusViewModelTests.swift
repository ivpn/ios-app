//
//  VPNStatusViewModelTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-16.
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

class VPNStatusViewModelTests: XCTestCase {
    
    var viewModel = VPNStatusViewModel(status: .invalid)
    
    func test_protectionStatusText() {
        viewModel.status = .connecting
        XCTAssertEqual(viewModel.protectionStatusText, "connecting")
        
        viewModel.status = .reasserting
        XCTAssertEqual(viewModel.protectionStatusText, "connecting")
        
        viewModel.status = .disconnecting
        XCTAssertEqual(viewModel.protectionStatusText, "disconnecting")
        
        viewModel.status = .connected
        XCTAssertEqual(viewModel.protectionStatusText, "connected")
        
        viewModel.status = .disconnected
        XCTAssertEqual(viewModel.protectionStatusText, "disconnected")
        
        viewModel.status = .invalid
        XCTAssertEqual(viewModel.protectionStatusText, "disconnected")
    }
    
    func test_connectToServerText() {
        viewModel.status = .connecting
        XCTAssertEqual(viewModel.connectToServerText, "Connecting to")
        
        viewModel.status = .reasserting
        XCTAssertEqual(viewModel.connectToServerText, "Connecting to")
        
        viewModel.status = .disconnecting
        XCTAssertEqual(viewModel.connectToServerText, "Disconnecting from")
        
        viewModel.status = .connected
        XCTAssertEqual(viewModel.connectToServerText, "Connected to")
        
        viewModel.status = .disconnected
        XCTAssertEqual(viewModel.connectToServerText, "Connect to")
        
        viewModel.status = .invalid
        XCTAssertEqual(viewModel.connectToServerText, "Connect to")
    }
    
    func test_connectToggleIsOn() {
        viewModel.status = .connecting
        XCTAssertTrue(viewModel.connectToggleIsOn)
        
        viewModel.status = .reasserting
        XCTAssertTrue(viewModel.connectToggleIsOn)
        
        viewModel.status = .connected
        XCTAssertTrue(viewModel.connectToggleIsOn)
        
        viewModel.status = .disconnecting
        XCTAssertFalse(viewModel.connectToggleIsOn)
        
        viewModel.status = .disconnected
        XCTAssertFalse(viewModel.connectToggleIsOn)
        
        viewModel.status = .invalid
        XCTAssertFalse(viewModel.connectToggleIsOn)
    }
    
    func test_popupStatusText() {
        viewModel.status = .connecting
        XCTAssertEqual(viewModel.popupStatusText, "Connecting")
        
        viewModel.status = .reasserting
        XCTAssertEqual(viewModel.popupStatusText, "Connecting")
        
        viewModel.status = .disconnecting
        XCTAssertEqual(viewModel.popupStatusText, "Disconnecting")
        
        viewModel.status = .connected
        XCTAssertEqual(viewModel.popupStatusText, "Connected to")
        
        viewModel.status = .disconnected
        XCTAssertEqual(viewModel.popupStatusText, "Your current location")
        
        viewModel.status = .invalid
        XCTAssertEqual(viewModel.popupStatusText, "Your current location")
    }
    
}
