//
//  StorageManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-11-22.
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
import CoreData
import NetworkExtension

class StorageManager {
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                log(.error, message: "Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    static func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                log(.error, message: "Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func clearSession() {
        remove(entityName: "Network")
        remove(entityName: "Server")
        remove(entityName: "CustomPort")
    }
    
    static func remove(entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context.execute(request)
        } catch {}
    }
    
}

// MARK: - Network Protection -

extension StorageManager {
    
    static func saveDefaultNetwork() {
        guard fetchNetworks(isDefault: true) == nil else { return }
        saveNetwork(name: "Default", isDefault: true)
    }
    
    static func saveCellularNetwork() {
        guard fetchNetworks(type: NetworkType.cellular.rawValue) == nil else { return }
        saveNetwork(name: "Mobile data", type: NetworkType.cellular.rawValue, trust: NetworkTrust.Default.rawValue)
    }
    
    static func saveWiFiNetwork(name: String) {
        guard fetchNetworks(name: name, type: NetworkType.wifi.rawValue) == nil else { return }
        saveNetwork(name: name, type: NetworkType.wifi.rawValue, trust: NetworkTrust.Default.rawValue)
    }
    
    static func saveNetwork(name: String = "", type: String = NetworkType.none.rawValue, trust: String = NetworkTrust.None.rawValue, isDefault: Bool = false) {
        let network = Network(context: context)
        network.name = name
        network.type = type
        network.trust = trust
        network.isDefault = isDefault
        saveContext()
    }
    
    static func fetchNetworks(name: String = "", type: String = NetworkType.none.rawValue, isDefault: Bool = false) -> [Network]? {
        let request: NSFetchRequest<Network> = Network.fetchRequest(name: name, type: type, isDefault: isDefault)
        
        do {
            let result = try context.fetch(request)
            if !result.isEmpty {
                return result
            }
        } catch {
            log(.error, message: "Coult not load collection from StorageManager")
        }
        
        return nil
    }
    
    static func fetchDefaultNeworks() -> [Network]? {
        var networks = [Network]()
        
        if let defaultNetworks = fetchNetworks(isDefault: true) {
            if let first = defaultNetworks.first {
                networks.append(first)
            }
        }
        
        if let cellularNetworks = fetchNetworks(type: NetworkType.cellular.rawValue) {
            if let first = cellularNetworks.first {
                networks.append(first)
            }
        }
        
        if !networks.isEmpty {
            return networks
        }
        
        return nil
    }
    
    static func getTrust(network: Network) -> String {
        if let networks = fetchNetworks(name: network.name ?? "", type: network.type ?? "") {
            if let first = networks.first {
                return first.trust ?? NetworkTrust.Default.rawValue
            }
        }
        
        return NetworkTrust.Default.rawValue
    }
    
    static func removeNetwork(name: String) {
        if let networks = fetchNetworks(name: name, type: NetworkType.wifi.rawValue) {
            if let network = networks.first {
                context.delete(network)
                saveContext()
            }
        }
    }
    
    static func saveCustomPort(vpnProtocol: String = "", type: String = "", port: Int = 0) {
        let customPort = CustomPort(context: context)
        customPort.vpnProtocol = vpnProtocol
        customPort.type = type
        customPort.port = Int32(port)
        saveContext()
    }
    
    static func fetchCustomPorts(vpnProtocol: String = "") -> [CustomPort]? {
        let request: NSFetchRequest<CustomPort> = CustomPort.fetchRequest(vpnProtocol: vpnProtocol)
        
        do {
            let result = try context.fetch(request)
            if !result.isEmpty {
                return result
            }
        } catch {
            log(.error, message: "Coult not load collection from StorageManager")
        }
        
        return nil
    }
    
}

// MARK: - NEOnDemandRule -

extension StorageManager {
    
    static func getOnDemandRules(status: NEVPNStatus) -> [NEOnDemandRule] {
        guard UserDefaults.shared.networkProtectionEnabled else { return [NEOnDemandRuleConnect()] }
        
        var onDemandRules = [NEOnDemandRule]()
        
        if let wifiOnDemandRules = getWiFiOnDemandRules(status: status) {
            onDemandRules.append(contentsOf: wifiOnDemandRules)
        }
        
        if let cellularOnDemandRule = getCellularOnDemandRule() {
            onDemandRules.append(cellularOnDemandRule)
        }
        
        if let defaultOnDemandRule = getDefaultOnDemandRule(status: status) {
            onDemandRules.append(defaultOnDemandRule)
        }
        
        return onDemandRules
    }
    
    static func getDefaultTrust() -> String {
        var defaultTrust = NetworkTrust.Default.rawValue
        
        if let defaultNetworks = fetchNetworks(isDefault: true) {
            if let network = defaultNetworks.first {
                defaultTrust = network.trust!
            }
        }
        
        return defaultTrust
    }
    
    static func trustValue(trust: String, defaultTrust: String) -> String {
        if trust == NetworkTrust.Default.rawValue {
            return defaultTrust
        }
        
        return trust
    }
    
    private static func getCellularNetwork() -> Network? {
        if let cellularNetworks = fetchNetworks(type: NetworkType.cellular.rawValue) {
            if let network = cellularNetworks.first {
                return network
            }
        }
        
        return nil
    }
    
    private static func getWiFiNetworks() -> [Network]? {
        if let networks = fetchNetworks(type: NetworkType.wifi.rawValue) {
            return networks
        }
        
        return nil
    }
    
    private static func getCellularOnDemandRule() -> NEOnDemandRule? {
        let defaults = UserDefaults.shared
        let defaultTrust = getDefaultTrust()
        
        guard let network = getCellularNetwork() else { return nil }
        
        let trust = trustValue(trust: network.trust!, defaultTrust: defaultTrust)
        
        guard trust != NetworkTrust.None.rawValue else { return nil }
        
        if trust == NetworkTrust.Untrusted.rawValue && defaults.networkProtectionUntrustedConnect {
            let onDemandRule = NEOnDemandRuleConnect()
            onDemandRule.interfaceTypeMatch = .cellular
            
            return onDemandRule
        }
        
        if trust == NetworkTrust.Trusted.rawValue && defaults.networkProtectionTrustedDisconnect {
            let onDemandRule = NEOnDemandRuleDisconnect()
            onDemandRule.interfaceTypeMatch = .cellular
            
            return onDemandRule
        }
        
        return nil
    }
    
    private static func getWiFiOnDemandRules(status: NEVPNStatus) -> [NEOnDemandRule]? {
        var onDemandRules = [NEOnDemandRule]()
        let defaults = UserDefaults.shared
        let defaultTrust = getDefaultTrust()
        
        guard let networks = getWiFiNetworks() else { return nil }
        
        let untrustedNetworks = networks.filter { trustValue(trust: $0.trust!, defaultTrust: defaultTrust) == NetworkTrust.Untrusted.rawValue }
        let trustedNetworks = networks.filter { trustValue(trust: $0.trust!, defaultTrust: defaultTrust) == NetworkTrust.Trusted.rawValue }
        
        if !untrustedNetworks.isEmpty && defaults.networkProtectionUntrustedConnect {
            let onDemandRule = NEOnDemandRuleConnect()
            onDemandRule.interfaceTypeMatch = .wiFi
            onDemandRule.ssidMatch = untrustedNetworks.map { $0.name! }
            onDemandRules.append(onDemandRule)
        }
        
        if !trustedNetworks.isEmpty && (defaults.networkProtectionTrustedDisconnect || status == .disconnected) {
            let onDemandRule = NEOnDemandRuleDisconnect()
            onDemandRule.interfaceTypeMatch = .wiFi
            onDemandRule.ssidMatch = trustedNetworks.map { $0.name! }
            onDemandRules.append(onDemandRule)
        }
        
        if !onDemandRules.isEmpty {
            return onDemandRules
        }
        
        return nil
    }
    
    private static func getDefaultOnDemandRule(status: NEVPNStatus) -> NEOnDemandRule? {
        let defaultTrust = getDefaultTrust()
        
        if defaultTrust == NetworkTrust.Untrusted.rawValue {
            return NEOnDemandRuleConnect()
        }
        if defaultTrust == NetworkTrust.Trusted.rawValue {
            return NEOnDemandRuleDisconnect()
        }
        
        switch status {
        case .connected:
            return NEOnDemandRuleConnect()
        case .disconnected, .invalid:
            return NEOnDemandRuleDisconnect()
        default:
            return nil
        }
    }
    
}

// MARK: - Server -

extension StorageManager {
    
    static func save(server: VPNServer, isFastestEnabled: Bool) {
        if let server = fetchServer(server: server) {
            server.isFastestEnabled = isFastestEnabled
        } else {
            let newServer = Server(context: context)
            newServer.gateway = server.gateway.replacingOccurrences(of: ".wg.", with: ".gw.")
            newServer.isFastestEnabled = isFastestEnabled
        }
        
        saveContext()
    }
    
    static func save(server: VPNServer, isFavorite: Bool) {
        if let server = fetchServer(server: server) {
            server.isFavorite = isFavorite
        } else {
            let newServer = Server(context: context)
            newServer.gateway = server.dnsName ?? server.gateway.replacingOccurrences(of: ".wg.", with: ".gw.")
            newServer.isFavorite = isFavorite
        }
        
        saveContext()
    }
    
    static func fetchServers(gateway: String = "", isFastestEnabled: Bool = false, isFavorite: Bool = false, isHost: Bool = false) -> [Server]? {
        let request: NSFetchRequest<Server> = Server.fetchRequest(gateway: gateway, isFastestEnabled: isFastestEnabled, isFavorite: isFavorite, isHost: isHost)
        
        do {
            let result = try context.fetch(request)
            if !result.isEmpty {
                return result
            }
        } catch {
            log(.error, message: "Coult not load collection from StorageManager")
        }
        
        return nil
    }
    
    static func fetchServer(server: VPNServer) -> Server? {
        if let servers = fetchServers(gateway: server.dnsName ?? server.gateway, isHost: server.isHost) {
            if let server = servers.first {
                return server
            }
        }
        
        return nil
    }
    
    static func isFastestEnabled(server vpnServer: VPNServer) -> Bool {
        if let server = fetchServer(server: vpnServer) {
            return server.isFastestEnabled
        }

        return false
    }
    
    static func isFavorite(server: VPNServer) -> Bool {
        if let servers = fetchServers(gateway: server.dnsName ?? server.gateway, isFavorite: true, isHost: server.isHost) {
            return !servers.isEmpty
        }

        return false
    }
    
    static func canUpdateServer(isOn: Bool) -> Bool {
        guard !isOn else {
            return true
        }
        
        if UserDefaults.standard.bool(forKey: UserDefaults.Key.fastestServerConfigured) {
            if let servers = fetchServers(isFastestEnabled: true) {
                if servers.count == 1 {
                    return false
                }
            }
        }
        
        return true
    }
    
}
