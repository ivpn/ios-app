//
//  VPNErrorObserver.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-02.
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

protocol VPNErrorObserverDelegate: class {
    func presentError(title: String, message: String)
}

class VPNErrorObserver {
    
    // MARK: - Properties -
    
    weak var delegate: VPNErrorObserverDelegate?
    private var wireguardErrorObserver: NSKeyValueObservation?
    
    // MARK: - Init -
    
    init() {
        addErrorObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(connectErrorObserver), name: Notification.Name.VPNConnectError, object: nil)
    }
    
    deinit {
        wireguardErrorObserver?.invalidate()
        wireguardErrorObserver = nil
    }
    
    // MARK: - Private methods -
    
    @objc private func connectErrorObserver() {
        switch Application.shared.settings.connectionProtocol.tunnelType() {
        case .ipsec:
            handleIKEv2Error()
        case .openvpn:
            handleOpenVPNError()
        case .wireguard:
            break
        }
    }
    
    private func handleIKEv2Error() {
        guard Application.shared.connectionManager.status != .connected else { return }
        
        NotificationCenter.default.post(name: Notification.Name.Disconnect, object: nil)
        
        delegate?.presentError(title: "Error", message: "IKEv2 tunnel failed with error: Authentication")
    }
    
    private func handleOpenVPNError() {
        let error = UserDefaults.shared.openvpnTunnelProviderError
        guard !error.isEmpty else { return }
        
        delegate?.presentError(title: "Error", message: "OpenVPN tunnel failed with error: \(error.camelCaseToCapitalized() ?? "")")
        
        UserDefaults.shared.set("", forKey: UserDefaults.Key.openvpnTunnelProviderError)
    }
    
    private func addErrorObservers() {
        let defaults = UserDefaults(suiteName: Config.appGroup)
        
        wireguardErrorObserver = defaults?.observe(\.wireguardTunnelProviderError, options: [.initial, .new]) { _, _ in
            guard defaults?.wireguardTunnelProviderError != "" else { return }
            
            defaults?.set("", forKey: UserDefaults.Key.wireguardTunnelProviderError)
            
            self.delegate?.presentError(title: "Error", message: "WireGuard tunnel failed to start. Check WireGuard public key and IP address in your settings.")
        }
    }
    
}
