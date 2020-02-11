//
//  Settings.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 7/20/18.
//  Copyright © 2018 IVPN. All rights reserved.
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
            UserDefaults.standard.synchronize()
        }
    }
    
    var selectedExitServer: VPNServer {
        didSet {
            UserDefaults.standard.set(selectedExitServer.gateway, forKey: "SelectedExitServerGateway")
            UserDefaults.standard.set(selectedExitServer.city, forKey: "SelectedExitServerCity")
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
        if connectionProtocol.tunnelType() == .wireguard {
            return "FastestServerConfiguredForWireGuard"
        } else {
            return "FastestServerConfiguredForOpenVPN"
        }
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
            }
        }
        
        if let savedExitGateway = UserDefaults.standard.string(forKey: "SelectedExitServerGateway") {
            if let lastUsedServer = serverList.getServer(byGateway: savedExitGateway) {
                selectedExitServer = lastUsedServer
            }
        }
        
        defaults?.set(selectedExitServer.getLocationFromGateway(), forKey: UserDefaults.Key.exitServerLocation)
        
        selectedServer.fastest = UserDefaults.standard.bool(forKey: "SelectedServerFastest")
        
        if let status = NEVPNStatus.init(rawValue: UserDefaults.standard.integer(forKey: "SelectedServerStatus")) {
            selectedServer.status = status
        }
    }
    
}
