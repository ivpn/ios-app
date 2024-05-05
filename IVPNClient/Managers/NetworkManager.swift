//
//  NetworkManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-11-22.
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

import UIKit
import Reachability

class NetworkManager {
    
    // MARK: - Properties -
    
    static let shared = NetworkManager()
    let reachability = try! Reachability()
    
    var isNetworkReachable: Bool {
        let reachability = try! Reachability()
        return reachability.connection != .unavailable
    }
    
    private var timer: Timer?
    
    // MARK: - Initialize -
    
    private init() {}
    
    // MARK: - Methods -
    
    func startMonitoring(completion: (() -> Void)? = nil) {
        reachability.whenReachable = { reachability in
            self.connectionUpdated(reachability: reachability)
            
            if let completion = completion {
                completion()
            }
        }
        
        reachability.whenUnreachable = { _ in
            self.updateNetwork(name: "No network", type: NetworkType.none.rawValue)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            log(.info, message: "Unable to start reachability notifier")
        }
        
        #warning("Remove network signal check after issue with VPN connections is resolved in Reachability.swift library")
        // More info: https://github.com/ashleymills/Reachability.swift/issues/195
        if Application.shared.settings.connectionProtocol.tunnelType() == .wireguard {
            startNetworkSignalCheck()
        }
    }
    
    func stopMonitoring() {
        reachability.stopNotifier()
        stopNetworkSignalCheck()
    }
    
    @objc func evaluateReachability() {
        let reachability = try! Reachability()
        connectionUpdated(reachability: reachability)
    }
    
    // MARK: - Private methods -
    
    private func connectionUpdated(reachability: Reachability) {
        switch reachability.connection {
        case .wifi:
            UIDevice.fetchWiFiSSID { [self] wiFiSSID in
                if let ssid = wiFiSSID {
                    StorageManager.saveWiFiNetwork(name: ssid)
                    NotificationCenter.default.post(name: Notification.Name.NetworkSaved, object: nil)
                    updateNetwork(name: ssid, type: NetworkType.wifi.rawValue)
                } else if Application.shared.connectionManager.status == .invalid {
                    updateNetwork(name: "Wi-Fi", type: NetworkType.none.rawValue)
                } else {
                    updateNetwork(name: "No network", type: NetworkType.none.rawValue)
                }
            }
        case .cellular:
            self.updateNetwork(name: "Mobile data", type: NetworkType.cellular.rawValue)
        case .unavailable, .none:
            self.updateNetwork(name: "No network", type: NetworkType.none.rawValue)
        }
    }
    
    private func updateNetwork(name: String, type: String) {
        let network = Network(context: StorageManager.context, needToSave: false)
        network.name = name
        network.type = type
        network.trust = StorageManager.getTrust(network: network)
        Application.shared.network = network
    }
    
    private func startNetworkSignalCheck() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(evaluateReachability), userInfo: nil, repeats: true)
    }
    
    private func stopNetworkSignalCheck() {
        timer?.invalidate()
        timer = nil
    }
    
}
