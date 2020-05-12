//
//  VPNStatusViewModelTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 16/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import XCTest

@testable import IVPNClient

class VPNStatusViewModelTests: XCTestCase {
    
    var viewModel = VPNStatusViewModel(status: .invalid)
    
    func testProtectionStatusText() {
        viewModel.status = .connecting
        XCTAssertEqual(viewModel.protectionStatusText, "Connecting")
        
        viewModel.status = .reasserting
        XCTAssertEqual(viewModel.protectionStatusText, "Connecting")
        
        viewModel.status = .disconnecting
        XCTAssertEqual(viewModel.protectionStatusText, "Disconnecting")
        
        viewModel.status = .connected
        XCTAssertEqual(viewModel.protectionStatusText, "Protected")
        
        viewModel.status = .disconnected
        XCTAssertEqual(viewModel.protectionStatusText, "Unprotected")
        
        viewModel.status = .invalid
        XCTAssertEqual(viewModel.protectionStatusText, "Unprotected")
    }
    
    func testConnectToServerText() {
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
    
    func testConnectToggleIsOn() {
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
    
    func testPopupStatusText() {
        viewModel.status = .connecting
        XCTAssertEqual(viewModel.connectToServerText, "Connecting VPN")
        
        viewModel.status = .reasserting
        XCTAssertEqual(viewModel.connectToServerText, "Connecting VPN")
        
        viewModel.status = .disconnecting
        XCTAssertEqual(viewModel.connectToServerText, "Disconnecting VPN")
        
        viewModel.status = .connected
        XCTAssertEqual(viewModel.connectToServerText, "Your connection is protected")
        
        viewModel.status = .disconnected
        XCTAssertEqual(viewModel.connectToServerText, "Everyone knows about your location")
        
        viewModel.status = .invalid
        XCTAssertEqual(viewModel.connectToServerText, "Everyone knows about your location")
    }
    
}
