//
//  NETunnelProviderProtocol+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-06-12.
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

import UIKit
import NetworkExtension
import Network
import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPN

extension NETunnelProviderProtocol {
    
    // MARK: OpenVPN
    
    static func makeOpenVPNProtocol(settings: ConnectionSettings, accessDetails: AccessDetails) -> NETunnelProviderProtocol {
        guard let host = getHost() else {
            return NETunnelProviderProtocol()
        }
        
        let username = accessDetails.username
        let socketType: SocketType = settings.protocolType() == "TCP" ? .tcp : .udp
        let credentials = OpenVPN.Credentials(username, KeyChain.vpnPassword ?? "")
        let staticKey = OpenVPN.StaticKey.init(file: OpenVPNConf.tlsAuth, direction: OpenVPN.StaticKey.Direction.client)
        let port = UInt16(getPort(settings: settings))
        
        var sessionBuilder = OpenVPN.ConfigurationBuilder()
        sessionBuilder.ca = OpenVPN.CryptoContainer(pem: OpenVPNConf.caCert)
        sessionBuilder.cipher = .aes256cbc
        sessionBuilder.compressionFraming = .disabled
        sessionBuilder.endpointProtocols = [EndpointProtocol(socketType, port)]
        sessionBuilder.hostname = host.host
        sessionBuilder.tlsWrap = OpenVPN.TLSWrap.init(strategy: .auth, key: staticKey!)
        
        if let dnsServers = openVPNdnsServers(), !dnsServers.isEmpty, dnsServers != [""] {
            sessionBuilder.dnsServers = dnsServers
            log(.info, message: "DNS server: \(dnsServers)")
            
            switch DNSProtocolType.preferred() {
            case .doh:
                sessionBuilder.dnsProtocol = .https
                sessionBuilder.dnsHTTPSURL = URL.init(string: DNSProtocolType.getServerURL(address: UserDefaults.shared.customDNS))
            case .dot:
                sessionBuilder.dnsProtocol = .tls
                sessionBuilder.dnsTLSServerName = DNSProtocolType.getServerName(address: UserDefaults.shared.customDNS)
            default:
                sessionBuilder.dnsProtocol = .plain
            }
        }
        
        var builder = OpenVPNProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.shouldDebug = true
        builder.debugLogFormat = "$Dyyyy-MM-dd HH:mm:ss$d $L $M"
        builder.masksPrivateData = true
        
        let configuration = builder.build()
        let keychain = Keychain(group: Config.appGroup)
        _ = try? keychain.set(password: credentials.password, for: credentials.username, context: Config.openvpnTunnelProvider)
        let proto = try! configuration.generatedTunnelProtocol(
            withBundleIdentifier: Config.openvpnTunnelProvider,
            appGroup: Config.appGroup,
            context: Config.openvpnTunnelProvider,
            credentials: credentials
        )
        proto.disconnectOnSleep = !UserDefaults.shared.keepAlive
        
        if #available(iOS 15.1, *) {
            if #available(iOS 16, *) { } else {
                proto.includeAllNetworks = UserDefaults.shared.killSwitch
            }
        }
        
        if #available(iOS 14.2, *) {
            proto.includeAllNetworks = disableLanAccess()
            proto.excludeLocalNetworks = !disableLanAccess()
        }
        
        return proto
    }
    
    static func openVPNdnsServers() -> [String]? {
        if UserDefaults.shared.isAntiTracker {
            if UserDefaults.shared.isAntiTrackerHardcore {
                if !UserDefaults.shared.antiTrackerHardcoreDNS.isEmpty {
                    return [UserDefaults.shared.antiTrackerHardcoreDNS]
                }
            } else {
                if !UserDefaults.shared.antiTrackerDNS.isEmpty {
                    return [UserDefaults.shared.antiTrackerDNS]
                }
            }
        } else if UserDefaults.shared.isCustomDNS && !UserDefaults.shared.customDNS.isEmpty {
            return UserDefaults.shared.resolvedDNSInsideVPN
        }
        
        return nil
    }
    
    // MARK: WireGuard
    
    static func makeWireGuardProtocol(settings: ConnectionSettings) -> NETunnelProviderProtocol {
        guard let host = getHost() else {
            return NETunnelProviderProtocol()
        }
        
        var addresses = KeyChain.wgIpAddress
        var publicKey = host.publicKey
        let port = getPort(settings: settings)
        var endpoint = Peer.endpoint(host: host.host, port: port)
        var v2raySettings = V2RaySettings.load()
        var v2rayInboundIp = host.host
        var v2rayInboundPort = v2raySettings?.singleHopInboundPort ?? 0
        let v2rayOutboundIp = host.v2ray
        let v2rayOutboundPort = port
        let v2rayDnsName = host.dnsName
        
        if UserDefaults.shared.isMultiHop, Application.shared.serviceStatus.isEnabled(capability: .multihop), let exitHost = getExitHost() {
            publicKey = exitHost.publicKey
            endpoint = Peer.endpoint(host: host.host, port: exitHost.multihopPort)
            v2rayInboundIp = exitHost.host
            v2rayInboundPort = exitHost.multihopPort
        }
        
        if let ipv6 = host.ipv6, UserDefaults.shared.isIPv6 {
            addresses = Interface.getAddresses(ipv4: KeyChain.wgIpAddress, ipv6: ipv6.localIP)
            KeyChain.wgIpAddresses = addresses
            KeyChain.wgIpv6Host = ipv6.localIP
        }
        
        if UserDefaults.shared.isV2ray && V2RayCore.shared.reconnectWithV2ray {
            endpoint = Peer.endpoint(host: Config.v2rayHost, port: Config.v2rayPort)
            v2raySettings?.inboundIp = v2rayInboundIp
            v2raySettings?.inboundPort = v2rayInboundPort
            v2raySettings?.outboundIp = v2rayOutboundIp
            v2raySettings?.outboundPort = v2rayOutboundPort
            v2raySettings?.dnsName = v2rayDnsName
            v2raySettings?.save()
        }
        
        let peer = Peer(
            publicKey: publicKey,
            presharedKey: KeyChain.wgPresharedKey,
            allowedIPs: Config.wgPeerAllowedIPs,
            endpoint: endpoint,
            persistentKeepalive: Config.wgPeerPersistentKeepalive
        )
        let interface = Interface(
            addresses: addresses,
            listenPort: Config.wgInterfaceListenPort,
            mtu: UserDefaults.standard.wgMtu,
            privateKey: KeyChain.wgPrivateKey,
            dns: host.localIPAddress()
        )
        let tunnel = Tunnel(
            tunnelIdentifier: UIDevice.uuidString(),
            title: Config.wireguardTunnelTitle,
            interface: interface,
            peers: [peer]
        )
        
        let configuration = NETunnelProviderProtocol()
        configuration.providerBundleIdentifier = Config.wireguardTunnelProvider
        configuration.serverAddress = peer.endpoint
        configuration.providerConfiguration = tunnel.generateProviderConfiguration()
        configuration.disconnectOnSleep = !UserDefaults.shared.keepAlive
        
        if #available(iOS 15.1, *) {
            if #available(iOS 16, *) { } else {
                configuration.includeAllNetworks = UserDefaults.shared.killSwitch
            }
        }
        
        if #available(iOS 14.2, *) {
            configuration.includeAllNetworks = disableLanAccess()
            configuration.excludeLocalNetworks = !disableLanAccess()
        }
        
        return configuration
    }
    
    // MARK: Methods
    
    private static func getHost() -> Host? {
        if let selectedHost = Application.shared.settings.selectedHost {
            return selectedHost
        }
        
        if let randomHost = Application.shared.settings.selectedServer.hosts.randomElement() {
            return randomHost
        }
        
        return nil
    }
    
    private static func getExitHost() -> Host? {
        if let selectedHost = Application.shared.settings.selectedExitHost {
            return selectedHost
        }
        
        if let randomHost = Application.shared.settings.selectedExitServer.hosts.randomElement() {
            return randomHost
        }
        
        return nil
    }
    
    private static func getPort(settings: ConnectionSettings) -> Int {
        if UserDefaults.shared.isMultiHop, Application.shared.serviceStatus.isEnabled(capability: .multihop), let exitHost = getExitHost() {
            return exitHost.multihopPort
        }
        
        return settings.port()
    }
    
    private static func disableLanAccess() -> Bool {
        let defaultTrust = StorageManager.getDefaultTrust()
        let networkTrust = Application.shared.network.trust ?? NetworkTrust.Default.rawValue
        let trust = StorageManager.trustValue(trust: networkTrust, defaultTrust: defaultTrust)
        
        if UserDefaults.shared.networkProtectionEnabled && UserDefaults.shared.networkProtectionUntrustedBlockLan && trust == NetworkTrust.Untrusted.rawValue {
            return true
        }
        
        return UserDefaults.shared.disableLanAccess
    }
    
}
