//
//  Tunnel.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 15/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

struct Tunnel {
    
    // MARK: - Properties -
    
    var tunnelIdentifier: String?
    var title: String?
    var interface: Interface?
    var peers: NSOrderedSet?
    
    // MARK: - Initialize -
    
    public init(tunnelIdentifier: String? = nil, title: String? = nil, interface: Interface? = nil, peers: NSOrderedSet? = nil) {
        self.tunnelIdentifier = tunnelIdentifier
        self.title = title
        self.interface = interface
        self.peers = peers
    }
    
    // MARK: - Methods -
    
    func generateProviderConfiguration() -> [String: Any] {
        var providerConfiguration = [String: Any]()
        
        providerConfiguration[PCKeys.title.rawValue] = self.title
        providerConfiguration[PCKeys.tunnelIdentifier.rawValue] = self.tunnelIdentifier
        providerConfiguration[PCKeys.endpoints.rawValue] = peers?.array.compactMap {($0 as? Peer)?.endpoint}.joined(separator: ", ")
        providerConfiguration[PCKeys.dns.rawValue] = interface?.dns
        providerConfiguration[PCKeys.addresses.rawValue] = interface?.addresses
        
        var settingsString = "replace_peers=true\n"
        
        if let interface = interface {
            settingsString += generateInterfaceProviderConfiguration(interface)
        }
        
        if let peers = peers?.array as? [Peer] {
            peers.forEach {
                settingsString += generatePeerProviderConfiguration($0)
            }
        }
        
        providerConfiguration["settings"] = settingsString
        
        return providerConfiguration
    }
    
    private func generateInterfaceProviderConfiguration(_ interface: Interface) -> String {
        var settingsString = ""
        
        if let hexPrivateKey = interface.privateKey?.base64KeyToHex() {
            settingsString += "private_key=\(hexPrivateKey)\n"
        }
        
        if interface.listenPort > 0 {
            settingsString += "listen_port=\(interface.listenPort)\n"
        }
        
        return settingsString
    }
    
    private func generatePeerProviderConfiguration(_ peer: Peer) -> String {
        var settingsString = ""
        
        if let hexPublicKey = peer.publicKey?.base64KeyToHex() {
            settingsString += "public_key=\(hexPublicKey)\n"
        }
        
        if let presharedKey = peer.presharedKey {
            settingsString += "preshared_key=\(presharedKey)\n"
        }
        
        if let endpoint = peer.endpoint {
            settingsString += "endpoint=\(endpoint)\n"
        }
        
        if peer.persistentKeepalive > 0 {
            settingsString += "persistent_keepalive_interval=\(peer.persistentKeepalive)\n"
        }
        
        if let allowedIPs = peer.allowedIPs?.commaSeparatedToArray() {
            allowedIPs.forEach {
                settingsString += "allowed_ip=\($0.trimmingCharacters(in: .whitespaces))\n"
            }
        }
        
        return settingsString
    }
    
}
