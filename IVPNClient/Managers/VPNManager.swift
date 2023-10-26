//
//  VPNManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2018-07-18.
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
import NetworkExtension
import UIKit
import TunnelKitCore
import TunnelKitOpenVPN

class VPNManager {
    
    // MARK: - Properties -
    
    private var ipsecManager: NEVPNManager?
    private var openvpnManager: NETunnelProviderManager?
    private var wireguardManager: NETunnelProviderManager?
    private var openvpnObserver: NSObjectProtocol?
    private var ipsecObserver: NSObjectProtocol?
    private var wireguardObserver: NSObjectProtocol?
    private(set) var accessDetails: AccessDetails?
    
    // MARK: - Methods -
    
    private func loadTunnelProviderManager(tunnelTitle: String, completion: @escaping (NETunnelProviderManager) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            guard error == nil else {
                log(.error, message: "Error loading VPN configuration: \(error?.localizedDescription ?? "Unkonwn")")
                return
            }
            
            var manager = NETunnelProviderManager()
            
            if let managers = managers {
                for managerObj in managers where managerObj.localizedDescription == tunnelTitle {
                    manager = managerObj
                    manager.loadFromPreferences(completionHandler: { _ in
                        completion(managerObj)
                    })
                    return
                }
            }
            
            manager.loadFromPreferences(completionHandler: { _ in
                completion(manager)
            })
        }
    }
    
    func loadIpSecManager(completion: @escaping (NEVPNManager) -> Void) {
        ipsecManager = NEVPNManager.shared()
        ipsecManager!.loadFromPreferences(completionHandler: { _ in
            completion(self.ipsecManager!)
        })
    }
    
    func getManagerFor(tunnelType: TunnelType, completion: @escaping (NEVPNManager) -> Void) {
        switch tunnelType {
        case .ipsec:
            if let ipsecManager = ipsecManager {
                completion(ipsecManager)
            } else {
                loadIpSecManager { manager in
                    completion(manager)
                }
            }
            return
        case .openvpn:
            if let openvpnManager = openvpnManager {
                completion(openvpnManager)
            } else {
                loadTunnelProviderManager(tunnelTitle: Config.openvpnTunnelTitle) { manager in
                    self.openvpnManager = manager
                    completion(manager)
                }
            }
            return
        case .wireguard:
            if let manager = wireguardManager {
                completion(manager)
            } else {
                loadTunnelProviderManager(tunnelTitle: Config.wireguardTunnelTitle) { manager in
                    self.wireguardManager = manager
                    completion(manager)
                }
            }
            return
        }
    }
    
    func setup(settings: ConnectionSettings, accessDetails: AccessDetails, status: NEVPNStatus? = nil, completion: @escaping (Error?) -> Void) {
        getManagerFor(tunnelType: settings.tunnelType()) { manager in
            guard manager.connection.status.isDisconnected() else {
                log(.error, message: "Trying to setup new VPN protocol, while previous connection is not disconnected")
                completion(nil)
                return
            }
            
            self.accessDetails = accessDetails
            
            if settings == .ipsec {
                self.setupNEVPNManager(manager: manager, accessDetails: accessDetails, status: status, completion: completion)
            } else {
                self.setupNETunnelProviderManager(manager: manager, settings: settings, accessDetails: accessDetails, status: status, completion: completion)
            }
        }
    }
    
    private func setupNEVPNManager(manager: NEVPNManager, accessDetails: AccessDetails, status: NEVPNStatus? = nil, completion: @escaping (Error?) -> Void) {
        let serverAddress = accessDetails.ipAddresses.randomElement() ?? accessDetails.serverAddress
        self.setupIKEv2Tunnel(manager: manager, accessDetails: accessDetails, serverAddress: serverAddress, status: status)
        manager.saveToPreferences { error in
            if let error = error, error.code == 5 {
                manager.isOnDemandEnabled = false
                if #available(iOS 15.1, *) {
                    if #available(iOS 16, *) { } else {
                        manager.protocolConfiguration?.includeAllNetworks = false
                    }
                }
                NotificationCenter.default.post(name: Notification.Name.VPNConfigurationDisabled, object: nil)
                return
            }
            
            manager.loadFromPreferences { _ in
                self.setupIKEv2Tunnel(manager: manager, accessDetails: accessDetails, serverAddress: serverAddress, status: status)
                manager.saveToPreferences { _ in
                    completion(nil)
                }
            }
        }
    }
    
    private func setupNETunnelProviderManager(manager: NEVPNManager, settings: ConnectionSettings, accessDetails: AccessDetails, status: NEVPNStatus? = nil, completion: @escaping (Error?) -> Void) {
        var serverAddress: String?
        switch settings {
        case .ipsec:
            break
        case .openvpn:
            self.setupOpenVPNTunnel(settings: settings, accessDetails: accessDetails, status: status)
            serverAddress = openvpnManager?.protocolConfiguration?.serverAddress
        case .wireguard:
            self.setupWireGuardTunnel(settings: settings, accessDetails: accessDetails, status: status)
            serverAddress = wireguardManager?.protocolConfiguration?.serverAddress
        }
        
        manager.saveToPreferences { error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            manager.loadFromPreferences { _ in
                if let serverAddress = serverAddress {
                    manager.protocolConfiguration?.serverAddress = serverAddress
                }
                manager.saveToPreferences { _ in
                    completion(nil)
                }
            }
        }
    }
    
    private func setupIKEv2Tunnel(manager: NEVPNManager, accessDetails: AccessDetails, serverAddress: String, status: NEVPNStatus? = nil) {
        let configuration = NEVPNProtocolIKEv2()
        configuration.remoteIdentifier = accessDetails.serverAddress
        configuration.localIdentifier = accessDetails.username
        configuration.serverAddress = serverAddress
        configuration.username = accessDetails.username
        configuration.passwordReference = accessDetails.passwordRef
        configuration.authenticationMethod = .none
        configuration.useExtendedAuthentication = true
        configuration.disconnectOnSleep = !UserDefaults.shared.keepAlive
        
        // Child IPSec security associations to be negotiated for each IKEv2 policy
        configuration.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256 // AES_CBC_256
        configuration.childSecurityAssociationParameters.diffieHellmanGroup = .group14 // MODP_2048
        configuration.childSecurityAssociationParameters.integrityAlgorithm = .SHA256 // HMAC_SHA2_256_128
        
        // Initial IKE security association to be negotiated with the IKEv2 server
        configuration.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256 // AES_CBC_256
        configuration.ikeSecurityAssociationParameters.diffieHellmanGroup = .group14 // MODP_2048
        configuration.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA256 // HMAC_SHA2_256_128
        
        manager.localizedDescription = Config.ikev2TunnelTitle
        manager.protocolConfiguration = configuration
        manager.onDemandRules = StorageManager.getOnDemandRules(status: status ?? .connected)
        manager.isOnDemandEnabled = true
        manager.isEnabled = true
    }
    
    private func setupOpenVPNTunnel(settings: ConnectionSettings, accessDetails: AccessDetails, status: NEVPNStatus? = nil) {
        guard let manager = openvpnManager else { return }
        
        manager.protocolConfiguration = NETunnelProviderProtocol.makeOpenVPNProtocol(settings: settings, accessDetails: accessDetails)
        manager.localizedDescription = Config.openvpnTunnelTitle
        manager.onDemandRules = StorageManager.getOnDemandRules(status: status ?? .connected)
        manager.isOnDemandEnabled = true
        manager.isEnabled = true
    }
    
    private func setupWireGuardTunnel(settings: ConnectionSettings, accessDetails: AccessDetails, status: NEVPNStatus? = nil) {
        guard let manager = wireguardManager else {
            return
        }
        
        manager.protocolConfiguration = NETunnelProviderProtocol.makeWireGuardProtocol(settings: settings)
        manager.localizedDescription = Config.wireguardTunnelTitle
        manager.onDemandRules = StorageManager.getOnDemandRules(status: status ?? .connected)
        manager.isOnDemandEnabled = true
        manager.isEnabled = true
    }
    
    func installOnDemandRules(settings: ConnectionSettings, accessDetails: AccessDetails) {
        switch settings {
        case .ipsec:
            disable(tunnelType: .openvpn) { _ in
                self.disable(tunnelType: .wireguard) { _ in
                    self.setup(settings: settings, accessDetails: accessDetails, status: .disconnected) { _ in
                        self.disconnect(tunnelType: .ipsec)
                    }
                }
            }
        case .openvpn:
            disable(tunnelType: .ipsec) { _ in
                self.disable(tunnelType: .wireguard) { _ in
                    self.setup(settings: settings, accessDetails: accessDetails, status: .disconnected) { _ in
                        DispatchQueue.delay(1) {
                            self.openvpnManager?.connection.stopVPNTunnel()
                        }
                    }
                }
            }
        case .wireguard:
            disable(tunnelType: .ipsec) { _ in
                self.disable(tunnelType: .openvpn) { _ in
                    self.setup(settings: settings, accessDetails: accessDetails, status: .disconnected) { _ in
                        DispatchQueue.delay(1) {
                            self.wireguardManager?.connection.stopVPNTunnel()
                        }
                    }
                }
            }
        }
    }
    
    func removeOnDemandRule(manager: NEVPNManager) {
        manager.loadFromPreferences { _ in
            manager.onDemandRules = [NEOnDemandRule]()
            manager.isOnDemandEnabled = false
            if #available(iOS 15.1, *) {
                if #available(iOS 16, *) { } else {
                    manager.protocolConfiguration?.includeAllNetworks = false
                }
            }
            manager.saveToPreferences { _ in }
        }
    }
    
    func disconnect(tunnelType: TunnelType, reconnectAutomatically: Bool = false) {
        getManagerFor(tunnelType: tunnelType) { [self] manager in
            manager.connection.stopVPNTunnel()
            
            if !UserDefaults.shared.networkProtectionEnabled || reconnectAutomatically {
                removeOnDemandRule(manager: manager)
            }
        }
    }
    
    func connect(tunnelType: TunnelType) {
        getManagerFor(tunnelType: tunnelType) { manager in
            manager.isEnabled = true
            
            do {
                try manager.connection.startVPNTunnel()
            } catch NEVPNError.configurationInvalid {
                log(.error, message: "Error connecting to VPN: configuration is invalid")
                manager.isOnDemandEnabled = false
                NotificationCenter.default.post(name: Notification.Name.VPNConfigurationDisabled, object: nil)
            } catch NEVPNError.configurationDisabled {
                log(.error, message: "Error connecting to VPN: configuration is disabled")
                manager.isOnDemandEnabled = false
                NotificationCenter.default.post(name: Notification.Name.VPNConfigurationDisabled, object: nil)
            } catch NEVPNError.configurationReadWriteFailed {
                log(.error, message: "Error connecting to VPN: configuration read write failed")
                manager.isOnDemandEnabled = false
                NotificationCenter.default.post(name: Notification.Name.VPNConfigurationDisabled, object: nil)
            } catch NEVPNError.configurationStale {
                log(.error, message: "Error connecting to VPN: configuration is stale")
            } catch NEVPNError.configurationUnknown {
                log(.error, message: "Error connecting to VPN: configuration is unknown")
            } catch NEVPNError.connectionFailed {
                log(.error, message: "Error connecting to VPN: connecting failed")
            } catch let error as NSError {
                log(.error, message: "Error connecting to VPN: \(error.localizedDescription)")
                NotificationCenter.default.post(name: Notification.Name.NEVPNStatusDidChange, object: nil)
            }
        }
    }
    
    func disable(tunnelType: TunnelType, completion: @escaping (Error?) -> Void) {
        getManagerFor(tunnelType: tunnelType) { manager in
            manager.loadFromPreferences { _ in
                manager.onDemandRules = [NEOnDemandRule]()
                manager.isOnDemandEnabled = false
                if #available(iOS 15.1, *) {
                    if #available(iOS 16, *) { } else {
                        manager.protocolConfiguration?.includeAllNetworks = false
                    }
                }
                manager.saveToPreferences(completionHandler: completion)
            }
        }
    }
    
    func remove(tunnelType: TunnelType, completion: @escaping (Error?) -> Void) {
        getManagerFor(tunnelType: tunnelType) { manager in
            manager.removeFromPreferences(completionHandler: completion)
        }
    }
    
    public func getStatus(tunnelType: TunnelType, completion: @escaping (TunnelType, NEVPNStatus) -> Void) {
        getManagerFor(tunnelType: tunnelType) { manager in
            completion(tunnelType, manager.connection.status)
        }
    }
    
    func removeStatusChangeUpdates() {
        if let ipsecObserver = ipsecObserver {
            NotificationCenter.default.removeObserver(ipsecObserver)
        }
        
        if let openvpnObserver = openvpnObserver {
            NotificationCenter.default.removeObserver(openvpnObserver)
        }
        
        if let wireguardObserver = wireguardObserver {
            NotificationCenter.default.removeObserver(wireguardObserver)
        }
    }
    
    func onStatusChanged(event: @escaping (TunnelType, NEVPNManager, NEVPNStatus) -> Void) {
        getManagerFor(tunnelType: .ipsec) { manager in
            self.ipsecObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name.NEVPNStatusDidChange,
                object: manager.connection, queue: OperationQueue.main) { _ in
                    log(.info, message: "IKEv2 connection status changed.")
                    log(.info, message: "IKEv2 status: \(manager.connection.status.rawValue)")
                    
                    event(TunnelType.ipsec, manager, manager.connection.status)
            }
        }
        
        getManagerFor(tunnelType: .openvpn) { manager in
            self.openvpnObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name.NEVPNStatusDidChange,
                object: manager.connection, queue: OperationQueue.main) { _ in
                    log(.info, message: "OpenVPN connection status changed.")
                    log(.info, message: "openvpn status: \(manager.connection.status.rawValue)")
                    
                    event(TunnelType.openvpn, manager, manager.connection.status)
            }
        }
        
        getManagerFor(tunnelType: .wireguard) { manager in
            self.wireguardObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name.NEVPNStatusDidChange,
                object: manager.connection, queue: OperationQueue.main) { _ in
                    log(.info, message: "WireGuard connection status changed.")
                    log(.info, message: "WireGuard status: \(manager.connection.status.rawValue)")
                    
                    event(TunnelType.wireguard, manager, manager.connection.status)
            }
        }
    }
    
    func getOpenVPNLog(completion: @escaping (String?) -> Void) {
        guard let session = openvpnManager?.connection as? NETunnelProviderSession else {
            completion(nil)
            return
        }
        
        do {
            try session.sendProviderMessage(OpenVPNProvider.Message.requestLog.data) { data in
                guard let data = data, !data.isEmpty else {
                    completion(nil)
                    return
                }
                
                guard let newestLog = String(data: data, encoding: .utf8), !newestLog.isEmpty else {
                    completion(nil)
                    return
                }
                
                completion(newestLog)
                return
            }
        } catch {
            completion(nil)
            return
        }
        
        completion(nil)
    }
    
    func getWireGuardLog(completion: @escaping (String?) -> Void) {
        guard let session = wireguardManager?.connection as? NETunnelProviderSession else {
            completion("Error")
            return
        }
        
        do {
            try session.sendProviderMessage(Message.requestLog.data) { _ in
                completion(nil)
                return
            }
        } catch {
            completion("Error")
            return
        }
        
        completion("Error")
    }
    
}

private enum Message: UInt8 {
    case requestLog = 99
    var data: Data {
        return Data([self.rawValue])
    }
}
