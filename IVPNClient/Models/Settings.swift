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
    
    // MARK: - Properties -
    
    var selectedServer: VPNServer {
        didSet {
            UserDefaults.standard.set(selectedServer.gateway, forKey: UserDefaults.Key.selectedServerGateway)
            UserDefaults.standard.set(selectedServer.city, forKey: UserDefaults.Key.selectedServerCity)
            UserDefaults.standard.set(selectedServer.fastest, forKey: UserDefaults.Key.selectedServerFastest)
            UserDefaults.standard.set(selectedServer.random, forKey: UserDefaults.Key.selectedServerRandom)
        }
    }
    
    var selectedExitServer: VPNServer {
        didSet {
            UserDefaults.standard.set(selectedExitServer.gateway, forKey: UserDefaults.Key.selectedExitServerGateway)
            UserDefaults.standard.set(selectedExitServer.city, forKey: UserDefaults.Key.selectedExitServerCity)
            UserDefaults.standard.set(selectedExitServer.random, forKey: UserDefaults.Key.selectedExitServerRandom)
            UserDefaults.shared.set(selectedExitServer.getLocationFromGateway(), forKey: UserDefaults.Key.exitServerLocation)
        }
    }
    
    var selectedHost: Host? {
        didSet {
            Host.save(selectedHost, key: UserDefaults.Key.selectedHost)
        }
    }
    
    var selectedExitHost: Host? {
        didSet {
            Host.save(selectedExitHost, key: UserDefaults.Key.selectedExitHost)
        }
    }
    
    var connectionProtocol: ConnectionSettings {
        didSet {
            saveConnectionProtocol()
        }
    }
    
    var serverListIsFavorite = false
    
    // MARK: - Initialize -

    init(serverList: VPNServerList) {
        connectionProtocol = ConnectionSettings.getSavedProtocol()
        
        selectedServer = serverList.servers.first ?? VPNServer(gateway: "Not loaded", countryCode: "US", country: "", city: "")
        selectedExitServer = serverList.getExitServer(entryServer: selectedServer)
        
        if let savedCity = UserDefaults.standard.string(forKey: UserDefaults.Key.selectedServerCity) {
            if let lastUsedServer = serverList.getServer(byCity: savedCity) {
                selectedServer = lastUsedServer
            }
        }
        
        if let savedGateway = UserDefaults.standard.string(forKey: UserDefaults.Key.selectedServerGateway) {
            if let lastUsedServer = serverList.getServer(byGateway: savedGateway) {
                selectedServer = lastUsedServer
            }
        }
        
        if let savedExitCity = UserDefaults.standard.string(forKey: UserDefaults.Key.selectedExitServerCity) {
            if let lastUsedServer = serverList.getServer(byCity: savedExitCity) {
                selectedExitServer = lastUsedServer
                selectedExitServer.random = UserDefaults.standard.bool(forKey: UserDefaults.Key.selectedExitServerRandom)
            }
        }
        
        if let savedExitGateway = UserDefaults.standard.string(forKey: UserDefaults.Key.selectedExitServerGateway) {
            if let lastUsedServer = serverList.getServer(byGateway: savedExitGateway) {
                selectedExitServer = lastUsedServer
                selectedExitServer.random = UserDefaults.standard.bool(forKey: UserDefaults.Key.selectedExitServerRandom)
            }
        }
        
        UserDefaults.shared.set(selectedExitServer.getLocationFromGateway(), forKey: UserDefaults.Key.exitServerLocation)
        saveConnectionProtocol()
        
        selectedServer.fastest = UserDefaults.standard.bool(forKey: UserDefaults.Key.selectedServerFastest)
        selectedServer.random = UserDefaults.standard.bool(forKey: UserDefaults.Key.selectedServerRandom)
        
        if let status = NEVPNStatus.init(rawValue: UserDefaults.standard.integer(forKey: UserDefaults.Key.selectedServerStatus)) {
            selectedServer.status = status
        }
        
        if selectedHost == nil {
            selectedHost = Host.load(key: UserDefaults.Key.selectedHost)
        }
        
        if selectedExitHost == nil {
            selectedExitHost = Host.load(key: UserDefaults.Key.selectedExitHost)
        }
    }
    
    // MARK: - Methods -
    
    func updateSelectedServerForMultiHop(isEnabled: Bool) {
        let selectedServer = Application.shared.settings.selectedServer
        if isEnabled, selectedServer.fastest, selectedServer == Application.shared.settings.selectedExitServer {
            if let server = Application.shared.serverList.getServers().first {
                server.fastest = false
                Application.shared.settings.selectedServer = server
                Application.shared.settings.selectedExitServer = Application.shared.serverList.getExitServer(entryServer: server)
                Application.shared.settings.selectedExitHost = nil
            }
        }
        
        if !isEnabled {
            Application.shared.settings.selectedServer.fastest = UserDefaults.standard.bool(forKey: UserDefaults.Key.fastestServerPreferred)
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
    
    func saveConnectionProtocol() {
        UserDefaults.standard.set(connectionProtocol.formatSave(), forKey: UserDefaults.Key.selectedProtocol)
        UserDefaults.shared.set(connectionProtocol.formatSave(), forKey: UserDefaults.Key.selectedProtocol)
    }
    
}
