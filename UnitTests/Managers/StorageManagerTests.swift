//
//  StorageManagerTests.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-12-26.
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
import CoreData

@testable import IVPNClient

class StorageManagerTests: XCTestCase {

    override func tearDown() {
        StorageManager.clearSession()
    }

    func test_saveDefaultNetwork() {
        StorageManager.saveDefaultNetwork()
        let networks = StorageManager.fetchNetworks(isDefault: true)
        if let network = networks?.first {
            XCTAssertTrue(network.isDefault)
            XCTAssertEqual(network.name, "Default")
        } else {
            XCTFail("Network not found")
        }
    }
    
    func test_saveCellularNetwork() {
        StorageManager.saveCellularNetwork()
        let networks = StorageManager.fetchNetworks(name: "Mobile data", type: NetworkType.cellular.rawValue)
        if let network = networks?.first {
            XCTAssertEqual(network.name, "Mobile data")
            XCTAssertEqual(network.type, NetworkType.cellular.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func test_saveWiFiNetwork() {
        StorageManager.saveWiFiNetwork(name: "Wi-Fi 1")
        let networks = StorageManager.fetchNetworks(name: "Wi-Fi 1", type: NetworkType.wifi.rawValue)
        if let network = networks?.first {
            XCTAssertEqual(network.name, "Wi-Fi 1")
            XCTAssertEqual(network.type, NetworkType.wifi.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func test_saveNetwork() {
        StorageManager.saveNetwork(name: "Wi-Fi 2", type: NetworkType.wifi.rawValue)
        let networks = StorageManager.fetchNetworks(name: "Wi-Fi 2", type: NetworkType.wifi.rawValue)
        if let network = networks?.first {
            XCTAssertEqual(network.name, "Wi-Fi 2")
            XCTAssertEqual(network.type, NetworkType.wifi.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func test_fetchDefaultNeworks() {
        StorageManager.saveDefaultNetwork()
        StorageManager.saveCellularNetwork()
        let networks = StorageManager.fetchDefaultNeworks()
        
        if let network = networks?.first {
            XCTAssertTrue(network.isDefault)
            XCTAssertEqual(network.name, "Default")
        } else {
            XCTFail("Network not found")
        }
        
        if let network = networks?.last {
            XCTAssertEqual(network.name, "Mobile data")
            XCTAssertEqual(network.type, NetworkType.cellular.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func test_getTrust() {
        StorageManager.saveCellularNetwork()
        let networks = StorageManager.fetchNetworks(name: "Mobile data", type: NetworkType.cellular.rawValue)
        if let network = networks?.first {
            let trust = StorageManager.getTrust(network: network)
            XCTAssertEqual(trust, NetworkTrust.Default.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func test_removeNetworks() {
        StorageManager.saveCellularNetwork()
        StorageManager.remove(entityName: "Network")
        let networks = StorageManager.fetchNetworks(name: "Mobile data", type: NetworkType.cellular.rawValue)
        XCTAssertTrue(networks?.isEmpty ?? true)
    }
    
    func test_removeNetwork() {
        StorageManager.saveWiFiNetwork(name: "Wi-Fi to remove")
        StorageManager.removeNetwork(name: "Wi-Fi to remove")
        let networks = StorageManager.fetchNetworks(name: "Wi-Fi to remove")
        XCTAssertNil(networks, "Network was not deleted")
    }
    
    func test_updateActiveNetwork() {
        let network = Network(context: StorageManager.context, needToSave: false)
        network.name = "Mobile data"
        network.type = NetworkType.cellular.rawValue
        network.trust = NetworkTrust.Default.rawValue
        Application.shared.network = network
        StorageManager.updateActiveNetwork(trust: NetworkTrust.Default.rawValue)
        XCTAssertEqual(Application.shared.network.trust, NetworkTrust.Default.rawValue)
    }

}
