//
//  StorageManager.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 22/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
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
                log(error: "Unresolved error \(error), \(error.userInfo)")
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
                log(error: "Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func clearSession() {
        remove(entityName: "Network")
        remove(entityName: "Server")
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
            log(error: "Coult not load collection from StorageManager")
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
    
    static func updateActiveNetwork(trust: String) {
        if let networks = fetchNetworks(name: Application.shared.network.name ?? "", type: Application.shared.network.type ?? "") {
            if let network = networks.first {
                network.trust = trust
                saveContext()
                Application.shared.network = network
                Application.shared.connectionManager.evaluateConnection()
            }
        }
    }
    
    static func removeNetwork(name: String) {
        if let networks = fetchNetworks(name: name, type: NetworkType.wifi.rawValue) {
            if let network = networks.first {
                context.delete(network)
                saveContext()
            }
        }
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
    
    static func saveServer(gateway: String, group: String, isFastestEnabled: Bool) {
        if let server = fetchServer(gateway: gateway) {
            server.isFastestEnabled = isFastestEnabled
        } else {
            let newServer = Server(context: context)
            newServer.gateway = gateway
            newServer.group = group
            newServer.isFastestEnabled = isFastestEnabled
        }
        
        saveContext()
    }
    
    static func fetchServers(gateway: String = "", group: String = "", isFastestEnabled: Bool = false) -> [Server]? {
        let request: NSFetchRequest<Server> = Server.fetchRequest(gateway: gateway, group: group, isFastestEnabled: isFastestEnabled)
        
        do {
            let result = try context.fetch(request)
            if !result.isEmpty {
                return result
            }
        } catch {
            log(error: "Coult not load collection from StorageManager")
        }
        
        return nil
    }
    
    static func fetchServer(gateway: String) -> Server? {
        if let servers = fetchServers(gateway: gateway) {
            if let server = servers.first {
                return server
            }
        }
        
        return nil
    }
    
    static func isFastestEnabled(server vpnServer: VPNServer) -> Bool {
        if let server = fetchServer(gateway: vpnServer.gateway) {
            return server.isFastestEnabled
        }

        return false
    }
    
    static func canUpdateServer(isOn: Bool) -> Bool {
        guard !isOn else { return true }
        
        let group = Application.shared.settings.fastestServerConfiguredKey
        
        if UserDefaults.standard.bool(forKey: group) {
            if let servers = fetchServers(group: group, isFastestEnabled: true) {
                if servers.count == 1 {
                    return false
                }
            }
        }
        
        return true
    }
    
}
