//
//  VPNServers.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/15/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class VPNServerList {
    
    // MARK: - Properties -
    
    open private(set) var servers: [VPNServer]
    
    var filteredFastestServers: [VPNServer] {
        var serversArray = servers
        let fastestServerConfiguredKey = Application.shared.settings.fastestServerConfiguredKey
        let fastestServerConfigured = UserDefaults.standard.bool(forKey: fastestServerConfiguredKey)
        
        if fastestServerConfigured {
            serversArray = serversArray.filter { StorageManager.isFastestEnabled(server: $0) }
        }
        
        return serversArray
    }
    
    // MARK: - Initialize -
    
    // This initializer without parameters will try to load either cached servers.json file
    // which was downloaded from the server, or if it is not found - use the default one,
    // which should be provided in App resources
    convenience init(bundleForDefaultResource: Bundle? = nil) {
        var data: Data?
        let cacheFileUrl = VPNServerList.cacheFileURL
        
        if FileManager.default.fileExists(atPath: cacheFileUrl.path) {
            data = FileSystemManager.loadDataFromUrl(resource: cacheFileUrl)
        }
        
        if data == nil {
            data = FileSystemManager.loadDataFromResource(
                resourceName: "servers",
                resourceType: "json",
                bundle: bundleForDefaultResource
            )
        }
        
        if Config.useDebugServers {
            data = FileSystemManager.loadDataFromResource(
                resourceName: "servers-dev",
                resourceType: "json",
                bundle: bundleForDefaultResource
            )
        }
        
        self.init(withJSONData: data)
    }
    
    // This will initialize the servers list file from the received data
    // and optionally save it to the cache file for later access
    init(withJSONData data: Data?, storeInCache: Bool = false) {
        servers = [VPNServer]()
        
        if let jsonData = data {
            var serversList: [[String: Any]]?
            var config: [String: Any]?
            
            do {
                let protocolKey = ConnectionSettings.serversListKey()
                let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
                
                if let list = json?[protocolKey] as? [[String: Any]] {
                    serversList = list
                } else {
                    serversList = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]]
                }
                
                if let configObj = json?["config"] as? [String: Any] {
                    config = configObj
                }
            } catch {
                let errorMessage = "Provided data cannot be deserialized: \(error)"
                log(error: errorMessage)
                return
            }
            
            if let serversList = serversList {
                createServersFromLoadedJSON(serversList)
                
                if servers.count > 0 && storeInCache {
                    FileSystemManager.deleteDocumentFile(VPNServerList.cacheFileURL)
                    try? jsonData.write(to: VPNServerList.cacheFileURL, options: .atomic)
                }
            }
            
            if let config = config {
                if let antitracker = config["antitracker"] as? [String: Any] {
                    if let defaultObj = antitracker["default"] as? [String: Any] {
                        if let ipAddress = defaultObj["ip"] as? String {
                            UserDefaults.shared.set(ipAddress, forKey: UserDefaults.Key.antiTrackerDNS)
                        }
                        if let ipAddressMultiHop = defaultObj["multihop-ip"] as? String {
                            UserDefaults.shared.set(ipAddressMultiHop, forKey: UserDefaults.Key.antiTrackerDNSMultiHop)
                        }
                    }
                    if let hardcore = antitracker["hardcore"] as? [String: Any] {
                        if let ipAddress = hardcore["ip"] as? String {
                            UserDefaults.shared.set(ipAddress, forKey: UserDefaults.Key.antiTrackerHardcoreDNS)
                        }
                        if let ipAddressMultiHop = hardcore["multihop-ip"] as? String {
                            UserDefaults.shared.set(ipAddressMultiHop, forKey: UserDefaults.Key.antiTrackerHardcoreDNSMultiHop)
                        }
                    }
                }
                
                if let api = config["api"] as? [String: Any] {
                    if let ips = api["ips"] as? [String?] {
                        UserDefaults.shared.set(ips, forKey: UserDefaults.Key.hostNames)
                    }
                }
            }
        }
    }
    
    // MARK: - Methods -
    
    static func removeCached() {
        if FileManager.default.fileExists(atPath: VPNServerList.cacheFileURL.path) {
            FileSystemManager.deleteDocumentFile(VPNServerList.cacheFileURL)
        }
    }
    
    static var cacheFileURL: URL = {
        return FileSystemManager.pathToDocumentFile(Config.serversListCacheFileName)
    }()
    
    func getServer(byIpAddress ipAddress: String) -> VPNServer? {
        return servers.first { $0.ipAddresses.first { $0 == ipAddress } != nil }
    }
    
    func getServer(byGateway gateway: String) -> VPNServer? {
        return servers.first { $0.gateway == gateway }
    }
    
    func getServer(byCity city: String) -> VPNServer? {
        return servers.first { $0.city == city }
    }
    
    func getFastestServer() -> VPNServer? {
        let servers = filteredFastestServers
        let serversWithPing = servers.filter { $0.pingMs ?? -1 >= 0 }
        if serversWithPing.isEmpty { return nil }
        
        return servers.min {
            let leftPingMs = $0.pingMs ?? -1
            let rightPingMs = $1.pingMs ?? -1
            if rightPingMs < 0 && leftPingMs >= 0 { return true }
            return leftPingMs < rightPingMs && leftPingMs > -1
        }
    }
    
    func validateServer(firstServer: VPNServer, secondServer: VPNServer) -> Bool {
        guard UserDefaults.shared.isMultiHop else { return true }
        guard firstServer.countryCode != secondServer.countryCode else { return false }
        
        return true
    }
    
    func getExitServer(entryServer: VPNServer) -> VPNServer {
        for server in servers where server.countryCode != entryServer.countryCode {
            return server
        }
        
        return VPNServer(gateway: "Not loaded", countryCode: "US", country: "", city: "")
    }
    
    func saveAllServers(exceptionGateway: String) {
        let group = Application.shared.settings.fastestServerConfiguredKey
        for server in servers {
            let isFastestEnabled = server.gateway != exceptionGateway
            StorageManager.saveServer(gateway: server.gateway, group: group, isFastestEnabled: isFastestEnabled)
        }
    }
    
    private func createServersFromLoadedJSON(_ serversList: [[String: Any]]) {
        servers.removeAll()
        
        for server in serversList {
            var serverIpList = [String]()
            var serverHostsList = [Host]()
            
            if let ipAddressList = server["ip_addresses"] as? [String?] {
                for ipAddress in ipAddressList where ipAddress != nil {
                    serverIpList.append(ipAddress!)
                }
            }
            
            if let hostsList = server["hosts"] as? [[String: Any]] {
                for host in hostsList {
                    if let hostIp = host["host"] as? String {
                        serverIpList.append(hostIp)
                    }
                    
                    let newHost = Host(
                        host: host["host"] as? String ?? "",
                        publicKey: host["public_key"] as? String ?? "",
                        localIP: host["local_ip"] as? String ?? ""
                    )
                    
                    serverHostsList.append(newHost)
                }
            }
            
            let newServer = VPNServer(
                gateway: server["gateway"] as? String ?? "",
                countryCode: server["country_code"] as? String ?? "",
                country: server["country"] as? String ?? "",
                city: server["city"] as? String ?? "",
                ipAddresses: serverIpList,
                hosts: serverHostsList
            )
            
            servers.append(newServer)
        }
        
        servers.sort { $0.countryCode == $1.countryCode ? $0.city < $1.city : $0.countryCode < $1.countryCode }
    }
    
}
