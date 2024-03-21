//
//  Pinger.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-11-26.
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

import Foundation

class Pinger {

    // MARK: - Properties -
    
    static let shared = Pinger()
    var serverList: VPNServerList
    
    private var count = 0
    
    // MARK: - Initialize -
    
    private init() {
        self.serverList = Application.shared.serverList
    }
    
    // MARK: - Methods -
    
    func ping() {
        guard evaluatePing() else { return }
        
        PingMannager.shared.stopPing()
        PingMannager.shared.pings = []
        UserDefaults.shared.set(Date().timeIntervalSince1970, forKey: "LastPingTimestamp")
        
        for server in serverList.getServers() {
            if let ipAddress = server.hosts.first?.host {
                guard !ipAddress.isEmpty else { continue }
                let ping = Ping()
                ping.delegate = self
                ping.host = ipAddress
                PingMannager.shared.add(ping)
            }
        }
        
        guard PingMannager.shared.pings.count > 0 else { return }
        
        PingMannager.shared.setup {
            PingMannager.shared.timeout = 5
            PingMannager.shared.startPing()
        }

        log(.info, message: "Pinger service started")
    }
    
    // MARK: - Private methods -
    
    private func evaluatePing() -> Bool {
        let lastPingTimestamp = UserDefaults.shared.integer(forKey: "LastPingTimestamp")
        let isPingTimeoutPassed = Date().timeIntervalSince1970 > Double(lastPingTimestamp) + Config.minPingCheckInterval
        return Application.shared.connectionManager.status.isDisconnected() && isPingTimeoutPassed
    }
    
}

// MARK: - PingDelegate -

extension Pinger: PingDelegate {
    
    func stop(_ ping: Ping) {
        
    }
    
    func ping(_ pinger: Ping, didFailWithError error: Error) {
        
    }
    
    func ping(_ pinger: Ping, didTimeoutWith result: PingResult) {
        pingResult(result)
    }
    
    func ping(_ pinger: Ping, didReceiveReplyWith result: PingResult) {
        pingResult(result)
    }
    
    func ping(_ pinger: Ping, didReceiveUnexpectedReplyWith result: PingResult) {
        pingResult(result)
    }
    
    func pingResult(_ result: PingResult) {
        guard let server = serverList.getServer(byIpAddress: result.host ?? "") else { return }
        
        if result.time > 0 {
            server.pingMs = Int(result.time * 1000)
            
            let isFastest = Application.shared.settings.selectedServer.fastest
            
            if server == Application.shared.settings.selectedServer {
                Application.shared.settings.selectedServer = server
                Application.shared.settings.selectedServer.fastest = isFastest
            }
            
            if server == Application.shared.settings.selectedExitServer {
                Application.shared.settings.selectedExitServer = server
            }
        }
        
        count += 1
        
        let pingsCount = PingMannager.shared.pings.count
        
        if count >= pingsCount {
            count = 0
            PingMannager.shared.stopPing()
            PingMannager.shared.pings = []
            if pingsCount > 0 {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name.PingDidComplete, object: nil)
                    log(.info, message: "Pinger service finished")
                }
            }
        }
    }
    
}
