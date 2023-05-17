//
//  Tunnel.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-15.
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
        providerConfiguration[PCKeys.mtu.rawValue] = interface?.mtu
        
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
