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
import WireGuardKit
import os
import WidgetKit

enum PacketTunnelProviderError: String, Error {
    case savedProtocolConfigurationIsInvalid
    case dnsResolutionFailure
    case couldNotStartBackend
    case couldNotDetermineFileDescriptor
    case couldNotSetNetworkSettings
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
    
    private var tunnelFileDescriptor: Int32? {
        var buf = [CChar](repeating: 0, count: Int(IFNAMSIZ))
        for fd: Int32 in 0...1024 {
            var len = socklen_t(buf.count)
            if getsockopt(fd, 2, 2, &buf, &len) == 0 && String(cString: buf).hasPrefix("utun") {
                return fd
            }
        }
        return nil
    }
    
    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard let addresses = UserDefaults.shared.isIPv6 ? KeyChain.wgIpAddresses : KeyChain.wgIpAddress, let wgPrivateKey = KeyChain.wgPrivateKey else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.couldNotStartBackend)
            return
        }
        
        guard let tunnelSettings = getTunnelSettings(ipAddress: addresses) else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.couldNotStartBackend)
            return
        }
        
        networkMonitor = NWPathMonitor()
        networkMonitor!.pathUpdateHandler = pathUpdate
        networkMonitor!.start(queue: DispatchQueue(label: "NetworkMonitor"))
        
        guard let privateKeyHex = wgPrivateKey.base64KeyToHex() else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.couldNotStartBackend)
            return
        }
        
        updatedSettings = settings.updateAttribute(key: "private_key", value: privateKeyHex)
        let handle = wgTurnOn(settings, tunnelFileDescriptor ?? 0)
        
        guard handle >= 0 else {
            tunnelSetupFailed()
            completionHandler(PacketTunnelProviderError.couldNotStartBackend)
            return
        }
        
        self.handle = handle
        
        startKeyRegenerationMonitor { error in
            completionHandler(error)
        }
        
        wg_log(.info, message: "Starting tunnel")
        wg_log(.info, message: "Public key: \(KeyChain.wgPublicKey ?? "")")
        
        setTunnelNetworkSettings(tunnelSettings) { error in
            if error != nil {
                self.tunnelSetupFailed()
                completionHandler(PacketTunnelProviderError.couldNotStartBackend)
            } else {
                WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
                completionHandler(nil)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        wg_log(.info, message: "Stopping tunnel")
        
        networkMonitor?.cancel()
        networkMonitor = nil
        
        if let handle = handle {
            wgTurnOff(handle)
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        completionHandler()
    }
    
    deinit {
        networkMonitor?.cancel()
    }
    
    private func tunnelSetupFailed() {
        wg_log(.error, message: "Tunnel setup failed")
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
        wg_log(.info, message: "Rotating keys")
        ExtensionKeyManager.shared.upgradeKey { privateKey, ipAddress in
            guard let privateKey = privateKey, let ipAddress = ipAddress else {
                completion(nil)
                return
            }
            
            guard let tunnelSettings = self.getTunnelSettings(ipAddress: ipAddress) else {
                completion(PacketTunnelProviderError.couldNotSetNetworkSettings)
                return
            }
            
            self.setTunnelNetworkSettings(tunnelSettings) { error in
                if error != nil {
                    completion(PacketTunnelProviderError.couldNotSetNetworkSettings)
                } else {
                    guard let privateKeyHex = privateKey.base64KeyToHex() else {
                        completion(PacketTunnelProviderError.couldNotSetNetworkSettings)
                        return
                    }
                    
                    wg_log(.info, message: "Update config with new key")
                    self.updateWgConfig(key: "private_key", value: privateKeyHex)
                    completion(nil)
                }
            }
        }
    }
    
    private func getTunnelSettings(ipAddress: String) -> NEPacketTunnelNetworkSettings? {
        let validatedEndpoints = (self.config.providerConfiguration?[PCKeys.endpoints.rawValue] as? String ?? "").commaSeparatedToArray().compactMap { ((try? WireGuardEndpoint(endpointString: String($0))) as WireGuardEndpoint??) }.compactMap {$0}
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
        } else if UserDefaults.shared.isCustomDNS && !UserDefaults.shared.customDNS.isEmpty && !UserDefaults.shared.resolvedDNSInsideVPN.isEmpty && UserDefaults.shared.resolvedDNSInsideVPN != [""] {
            switch DNSProtocolType.preferred() {
            case .doh:
                let dnsSettings = NEDNSOverHTTPSSettings(servers: UserDefaults.shared.resolvedDNSInsideVPN)
                dnsSettings.serverURL = URL.init(string: DNSProtocolType.getServerURL(address: UserDefaults.shared.customDNS))
                newSettings.dnsSettings = dnsSettings
            case .dot:
                let dnsSettings = NEDNSOverTLSSettings(servers: UserDefaults.shared.resolvedDNSInsideVPN)
                dnsSettings.serverName = DNSProtocolType.getServerName(address: UserDefaults.shared.customDNS)
                newSettings.dnsSettings = dnsSettings
            default:
                newSettings.dnsSettings = NEDNSSettings(servers: UserDefaults.shared.resolvedDNSInsideVPN)
            }
        }
        
        if let mtu = self.config.providerConfiguration![PCKeys.mtu.rawValue] as? NSNumber, mtu.intValue > 0 {
            newSettings.mtu = mtu
            wg_log(.info, message: "MTU: \(mtu)")
        }
        
        return newSettings
    }
    
    private func updateWgConfig(key: String, value: String) {
        guard let handle = handle else { return }
        let settings = self.settings.updateAttribute(key: key, value: value)
        updatedSettings = settings
        wg_log(.info, message: "Configuration updated")
        wgSetConfig(handle, settings)
    }
    
    private func pathUpdate(path: Network.NWPath) {
        guard let handle = handle else { return }
        wg_log(.info, message: "Network change detected: \(path.debugDescription)")
        wgSetConfig(handle, settings)
    }
    
}
