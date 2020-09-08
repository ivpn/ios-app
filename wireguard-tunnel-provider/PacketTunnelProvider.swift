//
//  PacketTunnelProvider.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-12.
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

import Network
import NetworkExtension

enum PacketTunnelProviderError: Error {
    case tunnelSetupFailed
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var handle: Int32?
    private var networkMonitor: NWPathMonitor?
    private var ifname: String?
    private var updatedSettings: String?
    
    private var config: NETunnelProviderProtocol {
        return self.protocolConfiguration as! NETunnelProviderProtocol
    }
    
    private var interfaceName: String {
        return config.providerConfiguration![PCKeys.title.rawValue]! as! String
    }
    
    private var settings: String {
        if let updatedSettings = updatedSettings {
            return updatedSettings
        }
        return config.providerConfiguration![PCKeys.settings.rawValue]! as! String
    }
    
    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard let wgIpAddress = KeyChain.wgIpAddress, let wgPrivateKey = KeyChain.wgPrivateKey else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.tunnelSetupFailed)
            return
        }
        
        UserDefaults.shared.set(wgIpAddress, forKey: UserDefaults.Key.localIpAddress)
        
        guard let tunnelSettings = getTunnelSettings(ipAddress: wgIpAddress) else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.tunnelSetupFailed)
            return
        }
        
        networkMonitor = NWPathMonitor()
        networkMonitor!.pathUpdateHandler = pathUpdate
        networkMonitor!.start(queue: DispatchQueue(label: "NetworkMonitor"))
        
        let fileDescriptor = (self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32) ?? -1
        
        guard let privateKeyHex = wgPrivateKey.base64KeyToHex() else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.tunnelSetupFailed)
            return
        }
        
        updatedSettings = settings.updateAttribute(key: "private_key", value: privateKeyHex)
        let handle = wgTurnOn(settings, fileDescriptor)
        
        guard handle >= 0 else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.tunnelSetupFailed)
            return
        }
        
        self.handle = handle
        
        startKeyRegenerationMonitor { error in
            completionHandler(error)
        }
        
        setTunnelNetworkSettings(tunnelSettings) { error in
            if error != nil {
                self.tunnelSetupFailed()
                completionHandler(PacketTunnelProviderError.tunnelSetupFailed)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        networkMonitor?.cancel()
        networkMonitor = nil
        
        if let handle = handle {
            wgTurnOff(handle)
        }
        
        completionHandler()
    }
    
    deinit {
        networkMonitor?.cancel()
    }
    
    private func tunnelSetupFailed() {
        UserDefaults.shared.set(".tunnelSetupFailed", forKey: UserDefaults.Key.wireguardTunnelProviderError)
        UserDefaults.shared.synchronize()
    }
    
    private func startKeyRegenerationMonitor(completion: @escaping (Error?) -> Void) {
        let timer = TimerManager(timeInterval: ExtensionKeyManager.regenerationCheckInterval)
        timer.eventHandler = {
            self.regenerateKeys { error in
                completion(error)
            }
            timer.proceed()
        }
        timer.resume()
    }
    
    private func regenerateKeys(completion: @escaping (Error?) -> Void) {
        ExtensionKeyManager.shared.upgradeKey { privateKey, ipAddress in
            guard let privateKey = privateKey, let ipAddress = ipAddress else {
                completion(nil)
                return
            }
            
            guard let tunnelSettings = self.getTunnelSettings(ipAddress: ipAddress) else {
                completion(PacketTunnelProviderError.tunnelSetupFailed)
                return
            }
            
            self.setTunnelNetworkSettings(tunnelSettings) { error in
                if error != nil {
                    completion(PacketTunnelProviderError.tunnelSetupFailed)
                } else {
                    guard let privateKeyHex = privateKey.base64KeyToHex() else {
                        completion(PacketTunnelProviderError.tunnelSetupFailed)
                        return
                    }
                    
                    self.updateWgConfig(key: "private_key", value: privateKeyHex)
                    UserDefaults.shared.set(ipAddress, forKey: UserDefaults.Key.localIpAddress)
                    completion(nil)
                }
            }
        }
    }
    
    private func getTunnelSettings(ipAddress: String) -> NEPacketTunnelNetworkSettings? {
        let validatedEndpoints = (self.config.providerConfiguration?[PCKeys.endpoints.rawValue] as? String ?? "").commaSeparatedToArray().compactMap { ((try? Endpoint(endpointString: String($0))) as Endpoint??) }.compactMap {$0}
        let validatedAddresses = ipAddress.commaSeparatedToArray().compactMap { ((try? CIDRAddress(stringRepresentation: String($0))) as CIDRAddress??) }.compactMap { $0 }
        
        guard let firstEndpoint = validatedEndpoints.first else {
            return nil
        }
        
        // We use the first endpoint for the ipAddress
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: firstEndpoint.ipAddress)
        newSettings.tunnelOverheadBytes = 80
        
        // IPv4 settings
        let validatedIPv4Addresses = validatedAddresses.filter { $0.addressType == .IPv4 }
        if validatedIPv4Addresses.count > 0 {
            let ipv4Settings = NEIPv4Settings(addresses: validatedIPv4Addresses.map { $0.ipAddress }, subnetMasks: validatedIPv4Addresses.map { $0.subnetString })
            ipv4Settings.includedRoutes = [NEIPv4Route.default()]
            ipv4Settings.excludedRoutes = validatedEndpoints.filter { $0.addressType == .IPv4 }.map {
                NEIPv4Route(destinationAddress: $0.ipAddress, subnetMask: "255.255.255.255")}
            
            newSettings.ipv4Settings = ipv4Settings
        }
        
        // IPv6 settings
        let validatedIPv6Addresses = validatedAddresses.filter { $0.addressType == .IPv6 }
        if validatedIPv6Addresses.count > 0 {
            let ipv6Settings = NEIPv6Settings(addresses: validatedIPv6Addresses.map { $0.ipAddress }, networkPrefixLengths: validatedIPv6Addresses.map { NSNumber(value: $0.subnet) })
            ipv6Settings.includedRoutes = [NEIPv6Route.default()]
            ipv6Settings.excludedRoutes = validatedEndpoints.filter { $0.addressType == .IPv6 }.map { NEIPv6Route(destinationAddress: $0.ipAddress, networkPrefixLength: 128) }
            
            newSettings.ipv6Settings = ipv6Settings
        }
        
        if let dns = self.config.providerConfiguration?[PCKeys.dns.rawValue] as? String {
            newSettings.dnsSettings = NEDNSSettings(servers: dns.commaSeparatedToArray())
        }
        
        if UserDefaults.shared.isAntiTracker {
            if UserDefaults.shared.isAntiTrackerHardcore {
                newSettings.dnsSettings = NEDNSSettings(servers: [UserDefaults.shared.antiTrackerHardcoreDNS])
            } else {
                newSettings.dnsSettings = NEDNSSettings(servers: [UserDefaults.shared.antiTrackerDNS])
            }
        } else if UserDefaults.shared.isCustomDNS && !UserDefaults.shared.customDNS.isEmpty {
            newSettings.dnsSettings = NEDNSSettings(servers: [UserDefaults.shared.customDNS])
        }
        
        if let mtu = self.config.providerConfiguration![PCKeys.mtu.rawValue] as? NSNumber, mtu.intValue > 0 {
            newSettings.mtu = mtu
        }
        
        return newSettings
    }
    
    private func updateWgConfig(key: String, value: String) {
        guard let handle = handle else { return }
        let settings = self.settings.updateAttribute(key: key, value: value)
        updatedSettings = settings
        wgSetConfig(handle, settings)
    }
    
    private func pathUpdate(path: Network.NWPath) {
        guard let handle = handle else { return }
        wgSetConfig(handle, settings)
    }
    
}
