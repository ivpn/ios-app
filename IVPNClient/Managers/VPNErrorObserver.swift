//
//  VPNErrorObserver.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 02/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
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
        NotificationCenter.default.addObserver(self, selector: #selector(connectErrorObserver), name: Notification.Name.ConnectError, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ConnectError, object: nil)
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
