//
//  VPNServers.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-15.
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
import CoreData
import UIKit
import CoreLocation

class VPNServerList {
    
    // MARK: - Properties -
    
    open private(set) var servers: [VPNServer]
    open private(set) var ports: [ConnectionSettings]
    open private(set) var portRanges: [PortRange]
    open private(set) var antiTrackerList: [AntiTrackerDns]
    
    var filteredFastestServers: [VPNServer] {
        if UserDefaults.standard.bool(forKey: UserDefaults.Key.fastestServerConfigured) {
            return getServers().filter { StorageManager.isFastestEnabled(server: $0) }
        }
        
        return getServers()
    }
    
    var noPing: Bool {
        let serversWithPing = servers.filter { $0.pingMs ?? -1 >= 0 }
        return serversWithPing.isEmpty
    }
    
    var antiTrackerBasicList: [AntiTrackerDns] {
        return antiTrackerList.filter { AntiTrackerDns.basicLists.contains($0.name) }
    }
    
    var antiTrackerIndividualList: [AntiTrackerDns] {
        return antiTrackerList.filter { !AntiTrackerDns.basicLists.contains($0.name) }
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
        ports = [ConnectionSettings]()
        portRanges = [PortRange]()
        antiTrackerList = [AntiTrackerDns]()
        
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
                log(.error, message: errorMessage)
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
                if let antiTrackerPlus = config["antitracker_plus"] as? [String: Any] {
                    if let jsonList = antiTrackerPlus["DnsServers"] as? [[String: Any]] {
                        var list = [AntiTrackerDns]()
                        for dns in jsonList {
                            list.append(AntiTrackerDns(
                                name: dns["Name"] as? String ?? "",
                                description: dns["Description"] as? String ?? "",
                                normal: dns["Normal"] as? String ?? "",
                                hardcore: dns["Hardcore"] as? String ?? ""
                            ))
                        }
                        antiTrackerList = list
                        
                        if AntiTrackerDns.load() == nil {
                            let defaultDns = AntiTrackerDns.defaultList(lists: antiTrackerList)
                            defaultDns?.save()
                        }
                    }
                }
                
                if let api = config["api"] as? [String: Any] {
                    if let ips = api["ips"] as? [String?] {
                        UserDefaults.shared.set(ips, forKey: UserDefaults.Key.hostNames)
                    }
                    
                    if let ips = api["ipv6s"] as? [String?] {
                        UserDefaults.shared.set(ips, forKey: UserDefaults.Key.ipv6HostNames)
                    }
                }
                
                if let portsObj = config["ports"] as? [String: Any] {
                    ports.append(ConnectionSettings.ipsec)
                    
                    if let openvpn = portsObj["openvpn"] as? [[String: Any]] {
                        var udpRanges = [CountableClosedRange<Int>]()
                        var tcpRanges = [CountableClosedRange<Int>]()
                        for port in openvpn {
                            if let portNumber = port["port"] as? Int {
                                if port["type"] as? String == "TCP" {
                                    ports.append(ConnectionSettings.openvpn(.tcp, portNumber))
                                } else {
                                    ports.append(ConnectionSettings.openvpn(.udp, portNumber))
                                }
                            }
                            if let range = port["range"] as? [String: Any] {
                                if let min = range["min"] as? Int, let max = range["max"] as? Int {
                                    if port["type"] as? String == "TCP" {
                                        tcpRanges.append(min...max)
                                    } else {
                                        udpRanges.append(min...max)
                                    }
                                }
                            }
                        }
                        if !udpRanges.isEmpty {
                            portRanges.append(PortRange(tunnelType: "OpenVPN", protocolType: "UDP", ranges: udpRanges))
                        }
                        if !tcpRanges.isEmpty {
                            portRanges.append(PortRange(tunnelType: "OpenVPN", protocolType: "TCP", ranges: tcpRanges))
                        }
                    }
                    
                    if let wireguard = portsObj["wireguard"] as? [[String: Any]] {
                        var ranges = [CountableClosedRange<Int>]()
                        for port in wireguard {
                            if let portNumber = port["port"] as? Int {
                                ports.append(ConnectionSettings.wireguard(.udp, portNumber))
                            }
                            if let range = port["range"] as? [String: Any] {
                                if let min = range["min"] as? Int, let max = range["max"] as? Int {
                                    ranges.append(min...max)
                                }
                            }
                        }
                        if !ranges.isEmpty {
                            portRanges.append(PortRange(tunnelType: "WireGuard", protocolType: "UDP", ranges: ranges))
                        }
                    }
                    
                    if let v2ray = portsObj["v2ray"] as? [String: Any] {
                        if let wireguard = v2ray["wireguard"] as? [[String: Any]] {
                            var ports = [V2RayPort]()
                            var inboundPort = 0
                            for port in wireguard {
                                let type = port["type"] as? String ?? ""
                                let port = port["port"] as? Int ?? 0
                                ports.append(V2RayPort(type: type, port: port))
                                inboundPort = port
                            }
                            let id = v2ray["id"] as? String ?? ""
                            let v2raySettings = V2RaySettings(id: id, inboundPort: inboundPort, wireguard: ports)
                            v2raySettings.save()
                        }
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
    
    func getServers() -> [VPNServer] {
        if UserDefaults.shared.isIPv6 && !UserDefaults.standard.showIPv4Servers {
            return servers.filter { (server: VPNServer) -> Bool in
                return server.enabledIPv6 || !server.supportsIPv6
            }
        }
        
        return servers
    }
    
    func getAllHosts(_ servers: [VPNServer]? = nil, isFavorite: Bool = false) -> [VPNServer] {
        var allHosts: [VPNServer] = []
        let allServers = servers ?? getServers()
        
        for server in allServers {
            if server.isHost {
                continue
            }
            
            if server.hosts.count == 1 {
                server.dnsName = server.hosts.first!.dnsName
            }
            
            allHosts.append(server)
            
            if isFavorite && server.hosts.count == 1 {
                continue
            }
            
            for host in server.hosts {
                allHosts.append(VPNServer(gateway: host.hostName, dnsName: host.dnsName, countryCode: server.countryCode, country: "", city: server.city, isp: server.isp, load: host.load, ipv6: host.ipv6))
            }
        }
        
        if isFavorite {
            return allHosts.filter { StorageManager.isFavorite(server: $0) }
        }
        
        return allHosts
    }
    
    func getServer(byIpAddress ipAddress: String) -> VPNServer? {
        return getServers().first { $0.hosts.first?.host == ipAddress }
    }
    
    func getServer(byGateway gateway: String) -> VPNServer? {
        return getServers().first { $0.gateway == gateway }
    }
    
    func getServer(byCity city: String) -> VPNServer? {
        return getServers().first { $0.city == city }
    }
    
    func getServer(byPrefix prefix: String) -> VPNServer? {
        return getAllHosts().first { $0.gateway.hasPrefix(prefix) }
    }
    
    func getHost(_ host: Host?) -> Host? {
        guard let host = host else {
            return nil
        }
        
        if let serverHost = getServer(byPrefix: host.hostNamePrefix()), let server = getServer(byCity: serverHost.city) {
            return server.getHost(fromPrefix: host.hostNamePrefix())
        }
        
        return nil
    }
    
    func getFastestServer() -> VPNServer? {
        let servers = filteredFastestServers
        if noPing {
            return Application.shared.settings.selectedServer
        }
        
        let server = servers.min {
            let leftPingMs = $0.pingMs ?? -1
            let rightPingMs = $1.pingMs ?? -1
            if rightPingMs < 0 && leftPingMs >= 0 { return true }
            return leftPingMs < rightPingMs && leftPingMs > -1
        }
        
        server?.fastest = true
        server?.random = false
        
        return server
    }
    
    func getExitServer(entryServer: VPNServer) -> VPNServer {
        for server in servers where server.countryCode != entryServer.countryCode {
            return server
        }
        
        return VPNServer(gateway: "Not loaded", countryCode: "US", country: "", city: "")
    }
    
    func getRandomServer(isExitServer: Bool) -> VPNServer {
        var list = [VPNServer]()
        let serverToValidate = isExitServer ? Application.shared.settings.selectedServer : Application.shared.settings.selectedExitServer
        
        list = servers.filter {
            VPNServer.validMultiHop($0, serverToValidate) &&
            VPNServer.validMultiHopCountry($0, serverToValidate, ignoreSettings: true) &&
            VPNServer.validMultiHopISP($0, serverToValidate, ignoreSettings: true)
        }
        
        if let randomServer = list.randomElement() {
            randomServer.fastest = false
            randomServer.random = true
            return randomServer
        }
        
        return VPNServer(gateway: "Not loaded", countryCode: "US", country: "", city: "")
    }
    
    func saveAllServers(exceptionGateway: String) {
        for server in servers {
            let isFastestEnabled = server.gateway != exceptionGateway
            StorageManager.save(server: server, isFastestEnabled: isFastestEnabled)
        }
    }
    
    func sortServers() {
        servers = VPNServerList.sort(servers)
    }
    
    func getPortRanges(tunnelType: String) -> [PortRange] {
        return portRanges.filter { $0.tunnelType == tunnelType }
    }
    
    static func sort(_ servers: [VPNServer]) -> [VPNServer] {
        let sort = ServersSort.init(rawValue: UserDefaults.shared.serversSort)
        var servers = servers
        
        switch sort {
        case .country:
            servers.sort { $0.countryCode == $1.countryCode ? $0.city < $1.city : $0.countryCode < $1.countryCode }
        case .latency:
            servers.sort { $0.pingMs ?? 5000 < $1.pingMs ?? 5000 }
        case .proximity:
            let geoLookup = Application.shared.geoLookup
            let location = CLLocation(latitude: geoLookup.latitude, longitude: geoLookup.longitude)
            servers.sort { $0.distance(to: location) < $1.distance(to: location) }
        default:
            servers.sort { $0.city < $1.city }
        }
        
        return servers
    }
    
    private func createServersFromLoadedJSON(_ serversList: [[String: Any]]) {
        servers.removeAll()
        
        for server in serversList {
            var serverHostsList = [Host]()
            
            if let hostsList = server["hosts"] as? [[String: Any]] {
                for host in hostsList {
                    var newHost = Host(
                        host: host["host"] as? String ?? "",
                        hostName: host["hostname"] as? String ?? "",
                        dnsName: host["dns_name"] as? String ?? "",
                        publicKey: host["public_key"] as? String ?? "",
                        localIP: host["local_ip"] as? String ?? "",
                        multihopPort: host["multihop_port"] as? Int ?? 0,
                        load: host["load"] as? Double ?? 0,
                        v2ray: host["v2ray"] as? String ?? ""
                    )
                    
                    if let ipv6 = host["ipv6"] as? [String: Any] {
                        newHost.ipv6 = IPv6(
                            localIP: ipv6["local_ip"] as? String ?? ""
                        )
                    }
                    
                    serverHostsList.append(newHost)
                }
            }
            
            let newServer = VPNServer(
                gateway: server["gateway"] as? String ?? "",
                countryCode: server["country_code"] as? String ?? "",
                country: server["country"] as? String ?? "",
                city: server["city"] as? String ?? "",
                latitude: server["latitude"] as? Double ?? 0,
                longitude: server["longitude"] as? Double ?? 0,
                isp: server["isp"] as? String ?? "",
                hosts: serverHostsList
            )
            
            servers.append(newServer)
        }
        
        DispatchQueue.async {
            self.sortServers()
        }
    }
    
}
