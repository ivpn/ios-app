//
//  ConnectionManager.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 7/20/18.
//  Copyright © 2018 IVPN. All rights reserved.
//

//
//  ConnectionManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2018-07-20.
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

class ConnectionManager {
    
    // MARK: - Properties -
    
    var reconnectAutomatically = false
    var settings: Settings
    var statusModificationDate = Date()
    
    var status: NEVPNStatus = .invalid {
        didSet {
            UserDefaults.shared.set(status.rawValue, forKey: UserDefaults.Key.connectionStatus)
        }
    }
    
    var isStatusStable: Bool {
        return Date().timeIntervalSince(statusModificationDate) >= Config.stableVPNStatusInterval
    }
    
    var canConnect: Bool {
        let defaultTrust = StorageManager.getDefaultTrust()
        let networkTrust = Application.shared.network.trust ?? NetworkTrust.Default.rawValue
        let trust = StorageManager.trustValue(trust: networkTrust, defaultTrust: defaultTrust)
        
        if trust == NetworkTrust.Trusted.rawValue {
            return false
        }
        
        return true
    }
    
    private var authentication: Authentication
    private var vpnManager: VPNManager
    private var connected = false
    private var closeApp = false
    private var actionType: ActionType = .connect
    
    // MARK: - Initialize -
    
    init(settings: Settings, authentication: Authentication, vpnManager: VPNManager) {
        self.vpnManager = vpnManager
        self.authentication = authentication
        self.settings = settings
    }
    
    // MARK: - Event handlers -

    func onStatusChanged(completion: @escaping (NEVPNStatus) -> Void) {
        vpnManager.onStatusChanged { _, _, status in
            if self.status == .connecting && status == .disconnecting {
                NotificationCenter.default.post(name: Notification.Name.VPNConnectError, object: nil)
            }
            
            self.status = status
            
            if status == .connected {
                self.connected = true
                DispatchQueue.delay(0.25) {
                    guard self.connected else {
                        NotificationCenter.default.post(name: Notification.Name.VPNConnectError, object: nil)
                        return
                    }
                    self.updateOpenVPNLogFile()
                    self.updateWireGuardLogFile()
                    self.reconnectAutomatically = false
                    if self.actionType == .connect {
                        self.evaluateCloseApp()
                    }
                }
                DispatchQueue.delay(2.5) {
                    if UserDefaults.shared.isV2ray && !V2RayCore.shared.reconnectWithV2ray {
                        V2RayCore.shared.reconnectWithV2ray = true
                        self.reconnect()
                    } else {
                        V2RayCore.shared.reconnectWithV2ray = false
                    }
                }
            } else {
                self.connected = false
            }
            
            if status == .disconnecting {
                self.updateOpenVPNLogFile()
                self.updateWireGuardLogFile()
            }
            
            if (status == .disconnected || status == .invalid) && self.reconnectAutomatically {
                if Application.shared.settings.connectionProtocol == .ipsec {
                    DispatchQueue.delay(0.25) {
                        self.connect()
                    }
                } else {
                    DispatchQueue.async {
                        self.connect()
                    }
                }
            }

            if status == .disconnected && self.actionType == .disconnect {
                self.evaluateCloseApp()
            }
            
            completion(status)
        }
    }
    
    // MARK: - Methods -
    
    func resetOnDemandRules() {
        if status.isDisconnected() {
            vpnManager.disable(tunnelType: .ipsec) { _ in }
            vpnManager.disable(tunnelType: .openvpn) { _ in }
            vpnManager.disable(tunnelType: .wireguard) { _ in }
        }
    }
    
    func removeOnDemandRules(completion: @escaping () -> Void) {
        getStatus { tunnelType, status in
            guard status != .invalid else {
                completion()
                return
            }
            
            self.vpnManager.disable(tunnelType: tunnelType) { _ in 
                completion()
            }
        }
    }
    
    func getStatus(completion: @escaping (TunnelType, NEVPNStatus) -> Void) {
        vpnManager.getStatus(tunnelType: .ipsec) { _, ipSecStatus in
            self.vpnManager.getStatus(tunnelType: .openvpn) { _, openVPNStatus in
                self.vpnManager.getStatus(tunnelType: .wireguard) { _, wireGuardStatus in
                    let selectedTunnelType = self.settings.connectionProtocol.tunnelType()
                    
                    self.combineStatus(
                        selectedTunnelType: selectedTunnelType,
                        ipSecStatus: ipSecStatus,
                        openVPNStatus: openVPNStatus,
                        wireGuardStatus: wireGuardStatus
                    ) { tunnelType, combinedStatus in
                        self.status = combinedStatus
                        completion(tunnelType, combinedStatus)
                    }
                }
            }
        }
    }
    
    func isOnDemandEnabled(completion: @escaping (Bool) -> Void) {
        vpnManager.getManagerFor(tunnelType: .ipsec) { manager in
            if manager.isOnDemandEnabled {
                completion(true)
                return
            }
            
            self.vpnManager.getManagerFor(tunnelType: .openvpn) { manager in
                if manager.isOnDemandEnabled {
                    completion(true)
                    return
                }
                
                self.vpnManager.getManagerFor(tunnelType: .wireguard) { manager in
                    if manager.isOnDemandEnabled {
                        completion(true)
                        return
                    }
                    
                    completion(false)
                }
            }
        }
    }
    
    func combineStatus(selectedTunnelType: TunnelType, ipSecStatus: NEVPNStatus, openVPNStatus: NEVPNStatus, wireGuardStatus: NEVPNStatus, completion: (TunnelType, NEVPNStatus) -> Void) {
        let meaningfulStatus = [NEVPNStatus.connected, NEVPNStatus.connecting, NEVPNStatus.disconnecting]
        
        if meaningfulStatus.contains(ipSecStatus) {
            completion(.ipsec, ipSecStatus)
            return
        }
        
        if meaningfulStatus.contains(openVPNStatus) {
            completion(.openvpn, openVPNStatus)
            return
        }
        
        if meaningfulStatus.contains(wireGuardStatus) {
            completion(.wireguard, wireGuardStatus)
            return
        }
        
        switch selectedTunnelType {
        case .ipsec:
            completion(.ipsec, ipSecStatus)
            return
        case .openvpn:
            completion(.openvpn, openVPNStatus)
            return
        case .wireguard:
            completion(.wireguard, wireGuardStatus)
            return
        }
    }
    
    func connect() {
        updateSelectedServer(status: .connecting)
        
        let host = NETunnelProviderProtocol.getHost()
        let accessDetails = AccessDetails(
            ipAddress: host?.host ?? settings.selectedServer.gateway,
            gateway: settings.selectedServer.gateway,
            username: KeyChain.vpnUsername ?? "",
            passwordRef: KeyChain.vpnPasswordRef
        )
        
        vpnManager.setup(
            settings: settings.connectionProtocol,
            accessDetails: accessDetails
        ) { error in
            guard error == nil else {
                NotificationCenter.default.post(name: Notification.Name.VPNConfigurationDisabled, object: nil)
                return
            }
            
            if UserDefaults.shared.isV2ray && V2RayCore.shared.reconnectWithV2ray {
                DispatchQueue.global(qos: .userInitiated).async {
                    let error = V2RayCore.shared.start()
                    if error != nil {
                        log(.error, message: error?.localizedDescription ?? "")
                    } else {
                        log(.info, message: "V2Ray start OK")
                    }
                }
            }
            
            self.vpnManager.connect(tunnelType: self.settings.connectionProtocol.tunnelType())
        }
    }
    
    func disconnect(reconnectAutomatically: Bool = false) {
        updateSelectedServer(status: .disconnecting)
        
        getStatus { tunnelType, _ in
            self.vpnManager.disconnect(tunnelType: tunnelType, reconnectAutomatically: reconnectAutomatically)
            
            if UserDefaults.shared.networkProtectionEnabled && !reconnectAutomatically {
                DispatchQueue.delay(2) {
                    self.installOnDemandRules()
                }
            }
        }
        
        if UserDefaults.shared.isV2ray {
            DispatchQueue.global(qos: .userInitiated).async {
                let error = V2RayCore.shared.close()
                if error != nil {
                    log(.error, message: error?.localizedDescription ?? "")
                } else {
                    log(.info, message: "V2Ray stop OK")
                }
            }
        }
    }
    
    func installOnDemandRules() {
        isOnDemandEnabled { [self] enabled in
            guard UserDefaults.shared.networkProtectionEnabled || enabled else {
                return
            }
            
            guard Application.shared.settings.connectionProtocol.tunnelType() != .wireguard || KeyChain.wgPublicKey != nil && KeyChain.wgIpAddress != nil else {
                return
            }
            
            guard status != .connected && status != .invalid else {
                return
            }
            
            let host = NETunnelProviderProtocol.getHost()
            let accessDetails = AccessDetails(
                ipAddress: host?.host ?? settings.selectedServer.gateway,
                gateway: settings.selectedServer.gateway,
                username: KeyChain.vpnUsername ?? "",
                passwordRef: KeyChain.vpnPasswordRef
            )
            let settings = self.settings.connectionProtocol
            vpnManager.installOnDemandRules(settings: settings, accessDetails: accessDetails)
        }
    }
    
    func resetRulesAndConnect() {
        removeOnDemandRules {
            self.connect()
        }
    }
    
    func resetRulesAndDisconnect(reconnectAutomatically: Bool = false) {
        removeOnDemandRules {
            self.disconnect(reconnectAutomatically: reconnectAutomatically)
        }
    }
    
    func resetRulesAndConnectShortcut(closeApp: Bool = false, actionType: ActionType = .connect) {
        self.closeApp = closeApp
        self.actionType = actionType
        getStatus { _, status in
            guard self.canConnect else {
                NotificationCenter.default.post(name: Notification.Name.Connect, object: nil)
                return
            }
            
            if status == .disconnected || status == .invalid {
                self.resetRulesAndConnect()
            }
        }
    }
    
    func resetRulesAndDisconnectShortcut(closeApp: Bool = false, actionType: ActionType = .connect) {
        self.closeApp = closeApp
        self.actionType = actionType
        getStatus { _, status in
            guard self.canDisconnect(status: status) else {
                UIApplication.topViewController()?.showAlert(title: "Cannot disconnect", message: "IVPN cannot disconnect from the current network while it is marked \"Untrusted\"") { _ in
                    NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
                }
                return
            }
            
            if status != .disconnected && status != .invalid {
                self.resetRulesAndDisconnect()
            }
        }
    }
    
    func connectShortcut(closeApp: Bool = false, actionType: ActionType = .connect) {
        self.closeApp = closeApp
        self.actionType = actionType
        
        if status == .disconnected || status == .invalid {
            self.resetRulesAndConnect()
        }
    }
    
    func disconnectShortcut(closeApp: Bool = false, actionType: ActionType = .connect) {
        self.closeApp = closeApp
        self.actionType = actionType
        
        if status != .disconnected && status != .invalid {
            self.resetRulesAndDisconnect()
        }
    }
    
    func updateSelectedServer(status: NEVPNStatus? = nil) {
        guard Application.shared.settings.selectedServer.fastest else {
            if !UserDefaults.standard.showIPv4Servers && Application.shared.serverList.getServer(byGateway: Application.shared.settings.selectedServer.gateway) == nil {
                if let server = Application.shared.serverList.getServers().first {
                    Application.shared.settings.selectedServer = server
                }
            }
            
            return
        }
        
        guard let fastestServer = Application.shared.serverList.getFastestServer() else {
            return
        }
        
        settings.selectedServer = fastestServer
        settings.selectedServer.fastest = true
        Application.shared.settings.selectedServer = fastestServer
        Application.shared.settings.selectedServer.fastest = true
        
        if let status = status {
            settings.selectedServer.status = status
            Application.shared.settings.selectedServer.status = status
        }
    }
    
    func needsToUpdateSelectedServer() {
        guard status.isDisconnected() else {
            return
        }
        
        updateSelectedServer()
    }
    
    func canDisconnect(status: NEVPNStatus) -> Bool {
        guard UserDefaults.shared.networkProtectionEnabled else {
            return true
        }
        
        let defaultTrust = StorageManager.getDefaultTrust()
        let networkTrust = Application.shared.network.trust ?? NetworkTrust.Default.rawValue
        let trust = StorageManager.trustValue(trust: networkTrust, defaultTrust: defaultTrust)
        
        if status == .connected && trust == NetworkTrust.Untrusted.rawValue {
            return false
        }
        
        return true
    }
    
    func evaluateConnection(network: Network? = nil, newTrust: String? = nil, completion: @escaping (String?) -> Void) {
        let defaults = UserDefaults.shared
        guard defaults.networkProtectionEnabled else {
            return
        }
        
        log(.info, message: "Evaluating VPN connection for Network Protection")
        
        guard let networkTrust = Application.shared.network.trust else {
            return
        }
        
        let defaultTrust = StorageManager.getDefaultTrust()
        let trust = StorageManager.trustValue(trust: networkTrust, defaultTrust: defaultTrust)
        
        switch trust {
        case NetworkTrust.Untrusted.rawValue:
            if defaults.networkProtectionUntrustedConnect && status.isDisconnected() {
                guard Application.shared.settings.connectionProtocol.tunnelType() != .wireguard || KeyChain.wgPublicKey != nil && KeyChain.wgIpAddress != nil else {
                    completion("WireGuard keys are missing")
                    return
                }
                
                resetRulesAndConnect()
                return
            }
        case NetworkTrust.Trusted.rawValue:
            if defaults.networkProtectionTrustedDisconnect && !status.isDisconnected() {
                resetRulesAndDisconnect()
                return
            }
        default:
            break
        }
        
        if let network = network, let newTrust = newTrust {
            guard Application.shared.settings.connectionProtocol.tunnelType() != .wireguard || KeyChain.wgPublicKey != nil && KeyChain.wgIpAddress != nil else {
                completion("WireGuard keys are missing")
                return
            }
            
            needToInstallOnDemandRules(network: network, newTrust: newTrust)
        }
    }
    
    func needToReconnect(network: Network, newTrust: String) -> Bool {
        guard UserDefaults.shared.networkProtectionEnabled else {
            return false
        }
        
        let defaultTrust = StorageManager.getDefaultTrust()
        let trust = StorageManager.trustValue(trust: newTrust, defaultTrust: defaultTrust)
        
        if Application.shared.connectionManager.status == .connected && network.name == "Default" && newTrust == NetworkTrust.Trusted.rawValue && Application.shared.network.trust == NetworkTrust.Default.rawValue {
            return false
        }
        
        if Application.shared.connectionManager.status == .connected && (network.name != Application.shared.network.name || trust != NetworkTrust.Trusted.rawValue) {
            return true
        }
        
        return false
    }
    
    func needToInstallOnDemandRules(network: Network, newTrust: String) {
        guard UserDefaults.shared.networkProtectionEnabled, status.isDisconnected() else {
            return
        }
        
        let defaultTrust = StorageManager.getDefaultTrust()
        let trust = StorageManager.trustValue(trust: newTrust, defaultTrust: defaultTrust)
        
        if Application.shared.connectionManager.status.isDisconnected() && (network.name != Application.shared.network.name || trust != NetworkTrust.Untrusted.rawValue) {
            installOnDemandRules()
        }
    }
    
    func reconnect() {
        getStatus { tunnelType, status in
            if status == .connected || status == .connecting {
                self.reconnectAutomatically = true
                self.vpnManager.disconnect(tunnelType: tunnelType, reconnectAutomatically: true)
            }
        }
    }
    
    func removeStatusChangeUpdates() {
        vpnManager.removeStatusChangeUpdates()
    }
    
    func removeAll() {
        vpnManager.remove(tunnelType: .ipsec) { _ in }
        vpnManager.remove(tunnelType: .openvpn) { _ in }
        vpnManager.remove(tunnelType: .wireguard) { _ in }
        status = .invalid
    }
    
    func getOpenVPNLog(completion: @escaping (String?) -> Void) {
        vpnManager.getOpenVPNLog { log in
            completion(log)
        }
    }
    
    func getWireGuardLog(completion: @escaping (String?) -> Void) {
        vpnManager.getWireGuardLog { error in
            completion(error)
        }
    }
    
    private func updateOpenVPNLogFile() {
        guard UserDefaults.shared.isLogging else {
            return
        }
        guard Application.shared.settings.connectionProtocol.tunnelType() == .openvpn else {
            return
        }
        
        getOpenVPNLog { log in
            FileSystemManager.updateLogFile(newestLog: log, name: Config.openVPNLogFile, isLoggedIn: Application.shared.authentication.isLoggedIn)
        }
    }
    
    private func updateWireGuardLogFile() {
        guard UserDefaults.shared.isLogging else {
            return
        }
        guard Application.shared.settings.connectionProtocol.tunnelType() == .wireguard else {
            return
        }
        
        getWireGuardLog { _ in
            var wireGuardLog: String?
            let filePath = FileSystemManager.sharedFilePath(name: "WireGuard.log").path
            if let file = NSData(contentsOfFile: filePath) {
                wireGuardLog = String(data: file as Data, encoding: .utf8) ?? ""
            }
            
            FileSystemManager.updateLogFile(newestLog: wireGuardLog, name: Config.wireGuardLogFile, isLoggedIn: Application.shared.authentication.isLoggedIn)
        }
    }
    
    private func evaluateCloseApp() {
        if closeApp {
            closeApp = false
            DispatchQueue.delay(1.5) {
                UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
            }
        }
    }
    
}

extension ConnectionManager {
    
    enum ActionType {
        case connect
        case disconnect
    }
    
}
