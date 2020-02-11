//
//  Pinger.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 26/11/2019.
//  Copyright © 2019 IVPN. All rights reserved.
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
        
        for server in serverList.servers {
            if let ipAddress = server.ipAddresses.first {
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

        log(info: "Pinger service started")
    }
    
    // MARK: - Private methods -
    
    private func evaluatePing() -> Bool {
        let lastPingTimestamp = UserDefaults.shared.integer(forKey: "LastPingTimestamp")
        let isPingTimeoutPassed = Date().timeIntervalSince1970 > Double(lastPingTimestamp) + Config.minPingCheckInterval
        return Application.shared.settings.selectedServer.status.isDisconnected() && isPingTimeoutPassed
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
                    UserDefaults.shared.set(Date().timeIntervalSince1970, forKey: "LastPingTimestamp")
                    log(info: "Pinger service finished")
                }
            }
        }
    }
    
}
