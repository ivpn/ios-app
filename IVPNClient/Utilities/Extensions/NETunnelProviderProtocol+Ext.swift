//
//  NETunnelProviderProtocol+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 12/06/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation
import NetworkExtension
import TunnelKit

extension NETunnelProviderProtocol {
    
    // MARK: OpenVPN
    
    static func makeOpenVPNProtocol(settings: ConnectionSettings, accessDetails: AccessDetails) -> NETunnelProviderProtocol {
        var username = accessDetails.username
        
        if UserDefaults.shared.isMultiHop && Application.shared.serviceStatus.isEnabled(capability: .multihop) {
            username += "@\(UserDefaults.shared.exitServerLocation)"
        }
        
        let port = UInt16(settings.port())
        let socketType: SocketType = settings.protocolType() == "TCP" ? .tcp : .udp
        let credentials = OpenVPN.Credentials(username, KeyChain.vpnPassword ?? "")
        let staticKey = OpenVPN.StaticKey.init(file: OpenVPNConf.tlsAuth, direction: OpenVPN.StaticKey.Direction.client)
        
        var sessionBuilder = OpenVPN.ConfigurationBuilder()
        sessionBuilder.ca = OpenVPN.CryptoContainer(pem: OpenVPNConf.caCert)
        sessionBuilder.cipher = .aes256cbc
        sessionBuilder.compressionFraming = .disabled
        sessionBuilder.endpointProtocols = [EndpointProtocol(socketType, port)]
        sessionBuilder.hostname = accessDetails.serverAddress
        sessionBuilder.tlsWrap = OpenVPN.TLSWrap.init(strategy: .auth, key: staticKey!)
        
        if let dnsServers = openVPNdnsServers() {
            sessionBuilder.dnsServers = dnsServers
        }
        
        var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.shouldDebug = true
        builder.debugLogFormat = "$Ddd.MM.yyyy HH:mm:ss$d $L $M"
        builder.masksPrivateData = false
        
        let openVPNconfiguration = builder.build()
        let configuration = try! openVPNconfiguration.generatedTunnelProtocol(
            withBundleIdentifier: Config.openvpnTunnelProvider,
            appGroup: Config.appGroup,
            credentials: credentials
        )
        configuration.disconnectOnSleep = !UserDefaults.shared.keepAlive
        
        return configuration
    }
    
    static func openVPNdnsServers() -> [String]? {
        if UserDefaults.shared.isAntiTracker {
            if UserDefaults.shared.isAntiTrackerHardcore {
                if UserDefaults.shared.isMultiHop {
                    return [UserDefaults.shared.antiTrackerHardcoreDNSMultiHop]
                } else {
                    return [UserDefaults.shared.antiTrackerHardcoreDNS]
                }
            } else {
                if UserDefaults.shared.isMultiHop {
                    return [UserDefaults.shared.antiTrackerDNSMultiHop]
                } else {
                    return [UserDefaults.shared.antiTrackerDNS]
                }
            }
        } else if UserDefaults.shared.isCustomDNS && !UserDefaults.shared.customDNS.isEmpty {
            return [UserDefaults.shared.customDNS]
        }
        
        return nil
    }
    
    // MARK: WireGuard
    
    static func makeWireGuardProtocol(settings: ConnectionSettings) -> NETunnelProviderProtocol {
        guard let host = Application.shared.settings.selectedServer.hosts.first else {
            return NETunnelProviderProtocol()
        }
        
        let peer = Peer(
            publicKey: host.publicKey,
            allowedIPs: Config.wgPeerAllowedIPs,
            endpoint: Peer.endpoint(host: host.host, port: settings.port()),
            persistentKeepalive: Config.wgPeerPersistentKeepalive
        )
        let interface = Interface(
            addresses: KeyChain.wgIpAddress,
            listenPort: Config.wgInterfaceListenPort,
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
        
        return configuration
    }
    
}
