//
//  Settings.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2018-07-20.
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

import Foundation
import NetworkExtension

class Settings {
    
    private let defaults = UserDefaults(suiteName: Config.appGroup)
    
    var selectedServer: VPNServer {
        didSet {
            UserDefaults.standard.set(selectedServer.gateway, forKey: "SelectedServerGateway")
            UserDefaults.standard.set(selectedServer.city, forKey: "SelectedServerCity")
            UserDefaults.standard.set(selectedServer.fastest, forKey: "SelectedServerFastest")
            UserDefaults.standard.set(selectedServer.random, forKey: "SelectedServerRandom")
            UserDefaults.standard.synchronize()
        }
    }
    
    var selectedExitServer: VPNServer {
        didSet {
            UserDefaults.standard.set(selectedExitServer.gateway, forKey: "SelectedExitServerGateway")
            UserDefaults.standard.set(selectedExitServer.city, forKey: "SelectedExitServerCity")
            UserDefaults.standard.set(selectedExitServer.random, forKey: "SelectedExitServerRandom")
            UserDefaults.standard.synchronize()
            
            defaults?.set(selectedExitServer.getLocationFromGateway(), forKey: UserDefaults.Key.exitServerLocation)
            defaults?.synchronize()
        }
    }
    
    var connectionProtocol: ConnectionSettings {
        didSet {
            if let index = Config.supportedProtocols.firstIndex(where: {$0 == connectionProtocol}) {
                UserDefaults.standard.set(index, forKey: "selectedProtocolIndex")
            }
        }
    }
    
    var fastestServerConfiguredKey: String {
        return "FastestServerConfiguredForOpenVPN"
    }

    init(serverList: VPNServerList) {
        let protocolIndex = UserDefaults.standard.integer(forKey: "selectedProtocolIndex")
        
        selectedServer = serverList.servers.first ?? VPNServer(gateway: "Not loaded", countryCode: "US", country: "", city: "")
        selectedExitServer = serverList.getExitServer(entryServer: selectedServer)
        
        if Config.supportedProtocols.indices.contains(protocolIndex) {
            connectionProtocol = Config.supportedProtocols[protocolIndex]
        } else {
            connectionProtocol = Config.defaultProtocol
        }
        
        if let savedCity = UserDefaults.standard.string(forKey: "SelectedServerCity") {
            if let lastUsedServer = serverList.getServer(byCity: savedCity) {
                selectedServer = lastUsedServer
            }
        }
        
        if let savedGateway = UserDefaults.standard.string(forKey: "SelectedServerGateway") {
            if let lastUsedServer = serverList.getServer(byGateway: savedGateway) {
                selectedServer = lastUsedServer
            }
        }
        
        if let savedExitCity = UserDefaults.standard.string(forKey: "SelectedExitServerCity") {
            if let lastUsedServer = serverList.getServer(byCity: savedExitCity) {
                selectedExitServer = lastUsedServer
                selectedExitServer.random = UserDefaults.standard.bool(forKey: "SelectedExitServerRandom")
            }
        }
        
        if let savedExitGateway = UserDefaults.standard.string(forKey: "SelectedExitServerGateway") {
            if let lastUsedServer = serverList.getServer(byGateway: savedExitGateway) {
                selectedExitServer = lastUsedServer
                selectedExitServer.random = UserDefaults.standard.bool(forKey: "SelectedExitServerRandom")
            }
        }
        
        defaults?.set(selectedExitServer.getLocationFromGateway(), forKey: UserDefaults.Key.exitServerLocation)
        
        selectedServer.fastest = UserDefaults.standard.bool(forKey: "SelectedServerFastest")
        selectedServer.random = UserDefaults.standard.bool(forKey: "SelectedServerRandom")
        
        if let status = NEVPNStatus.init(rawValue: UserDefaults.standard.integer(forKey: "SelectedServerStatus")) {
            selectedServer.status = status
        }
    }
    
    func updateSelectedServerForMultiHop(isEnabled: Bool) {
        if isEnabled && Application.shared.settings.selectedServer.fastest {
            let server = Application.shared.serverList.servers.first!
            server.fastest = false
            Application.shared.settings.selectedServer = server
            Application.shared.settings.selectedExitServer = Application.shared.serverList.getExitServer(entryServer: server)
        }
        
        if !isEnabled {
            Application.shared.settings.selectedServer.fastest = UserDefaults.standard.bool(forKey: "FastestServerPreferred")
        }
    }
    
    func updateRandomServer() {
        if Application.shared.settings.selectedServer.random {
            Application.shared.settings.selectedServer = Application.shared.serverList.getRandomServer(isExitServer: false)
        }
        
        if Application.shared.settings.selectedExitServer.random {
            Application.shared.settings.selectedExitServer = Application.shared.serverList.getRandomServer(isExitServer: true)
        }
    }
    
}
