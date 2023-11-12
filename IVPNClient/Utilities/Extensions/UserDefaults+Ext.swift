//
//  UserDefaults+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-22.
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

extension UserDefaults {
    
    static var shared: UserDefaults {
        return UserDefaults(suiteName: Config.appGroup)!
    }
    
    struct Key {
        static let wireguardTunnelProviderError = "wireguardTunnelProviderError"
        static let openvpnTunnelProviderError = "TunnelKitLastError"
        static let isMultiHop = "isMultiHop"
        static let preventSameCountryMultiHop = "preventSameCountryMultiHop"
        static let preventSameISPMultiHop = "preventSameISPMultiHop"
        static let exitServerLocation = "exitServerLocation"
        static let isLogging = "isLogging"
        static let networkProtectionEnabled = "networkProtection.enabled"
        static let networkProtectionUntrustedConnect = "networkProtection.untrusted.connect"
        static let networkProtectionTrustedDisconnect = "networkProtection.trusted.disconnect"
        static let isCustomDNS = "isCustomDNS"
        static let customDNSProtocol = "customDNSProtocol"
        static let customDNS = "customDNS"
        static let isAntiTracker = "isAntiTracker"
        static let isAntiTrackerHardcore = "isAntiTrackerHardcore"
        static let antiTrackerDNS = "antiTrackerDNS"
        static let antiTrackerHardcoreDNS = "antiTrackerHardcoreDNS"
        static let wgKeyTimestamp = "wgKeyTimestamp"
        static let wgRegenerationRate = "wgRegenerationRate"
        static let wgMtu = "wgMtu"
        static let hostNames = "hostNames"
        static let ipv6HostNames = "ipv6HostNames"
        static let apiHostName = "apiHostName"
        static let hasUserConsent = "hasUserConsent"
        static let sessionsLimit = "sessionsLimit"
        static let upgradeToUrl = "upgradeToUrl"
        static let connectionStatus = "connectionStatus"
        static let connectionLocation = "connectionLocation"
        static let connectionIpAddress = "connectionIpAddress"
        static let connectionIpv6Address = "connectionIpv6Address"
        static let lastWidgetUpdate = "lastWidgetUpdate"
        static let geoLookup = "geoLookup"
        static let keepAlive = "keepAlive"
        static let serversSort = "serversSort"
        static let notAskToReconnect = "notAskToReconnect"
        static let selectedProtocol = "selectedProtocol"
        static let resolvedDNSInsideVPN = "resolvedDNSInsideVPN"
        static let resolvedDNSOutsideVPN = "resolvedDNSOutsideVPN"
        static let selectedServerCity = "SelectedServerCity"
        static let selectedServerGateway = "SelectedServerGateway"
        static let selectedServerRandom = "SelectedServerRandom"
        static let selectedServerFastest = "SelectedServerFastest"
        static let selectedServerStatus = "SelectedServerStatus"
        static let selectedExitServerCity = "SelectedExitServerCity"
        static let selectedExitServerGateway = "SelectedExitServerGateway"
        static let selectedExitServerRandom = "SelectedExitServerRandom"
        static let selectedHost = "SelectedHost"
        static let selectedExitHost = "SelectedExitHost"
        static let fastestServerPreferred = "FastestServerPreferred"
        static let fastestServerConfigured = "FastestServerConfiguredForOpenVPN"
        static let firstInstall = "FirstInstall"
        static let secureDNS = "SecureDNS"
        static let serviceStatus = "ServiceStatus"
        static let isIPv6 = "isIPv6"
        static let showIPv4Servers = "showIPv4Servers"
        static let killSwitch = "killSwitch"
        static let selectHost = "selectHost"
        static let isLoggedIn = "isLoggedIn"
        static let antiTrackerDns = "antiTrackerDns"
        static let disableLanAccess = "disableLanAccess"
        static let v2raySettings = "v2raySettings"
        static let v2rayProtocol = "v2rayProtocol"
        static let isV2ray = "isV2ray"
    }
    
    @objc dynamic var wireguardTunnelProviderError: String {
        return string(forKey: Key.wireguardTunnelProviderError) ?? ""
    }
    
    @objc dynamic var openvpnTunnelProviderError: String {
        return string(forKey: Key.openvpnTunnelProviderError) ?? ""
    }
    
    @objc dynamic var isMultiHop: Bool {
        return bool(forKey: Key.isMultiHop)
    }
    
    @objc dynamic var exitServerLocation: String {
        return string(forKey: Key.exitServerLocation) ?? ""
    }
    
    @objc dynamic var isLogging: Bool {
        return bool(forKey: Key.isLogging)
    }
    
    @objc dynamic var networkProtectionEnabled: Bool {
        return bool(forKey: Key.networkProtectionEnabled)
    }
    
    @objc dynamic var networkProtectionUntrustedConnect: Bool {
        return bool(forKey: Key.networkProtectionUntrustedConnect)
    }
    
    @objc dynamic var networkProtectionTrustedDisconnect: Bool {
        return bool(forKey: Key.networkProtectionTrustedDisconnect)
    }
    
    @objc dynamic var isCustomDNS: Bool {
        return bool(forKey: Key.isCustomDNS)
    }
    
    @objc dynamic var customDNS: String {
        return string(forKey: Key.customDNS) ?? ""
    }
    
    @objc dynamic var customDNSProtocol: String {
        return string(forKey: Key.customDNSProtocol) ?? "plain"
    }
    
    @objc dynamic var isAntiTracker: Bool {
        return bool(forKey: Key.isAntiTracker)
    }
    
    @objc dynamic var isAntiTrackerHardcore: Bool {
        return bool(forKey: Key.isAntiTrackerHardcore)
    }
    
    @objc dynamic var antiTrackerDNS: String {
        return AntiTrackerDns.load()?.normal ?? ""
    }
    
    @objc dynamic var antiTrackerHardcoreDNS: String {
        return AntiTrackerDns.load()?.hardcore ?? ""
    }
    
    @objc dynamic var wgKeyTimestamp: Date {
        if let date = object(forKey: Key.wgKeyTimestamp) as? Date {
            return date
        }
        
        return Date()
    }
    
    @objc dynamic var wgRegenerationRate: Int {
        return integer(forKey: Key.wgRegenerationRate)
    }
    
    @objc dynamic var wgMtu: Int {
        return integer(forKey: Key.wgMtu)
    }
    
    @objc dynamic var hostNames: [String] {
        return stringArray(forKey: Key.hostNames) ?? []
    }
    
    @objc dynamic var ipv6HostNames: [String] {
        return stringArray(forKey: Key.ipv6HostNames) ?? []
    }
    
    @objc dynamic var apiHostName: String {
        return string(forKey: Key.apiHostName) ?? Config.ApiHostName
    }
    
    @objc dynamic var hasUserConsent: Bool {
        return bool(forKey: Key.hasUserConsent)
    }
    
    @objc dynamic var sessionsLimit: Int {
        return integer(forKey: Key.sessionsLimit)
    }
    
    @objc dynamic var upgradeToUrl: String {
        return string(forKey: Key.upgradeToUrl) ?? ""
    }
    
    @objc dynamic var keepAlive: Bool {
        return bool(forKey: Key.keepAlive)
    }
    
    @objc dynamic var serversSort: String {
        return string(forKey: Key.serversSort) ?? ""
    }
    
    @objc dynamic var notAskToReconnect: Bool {
        return bool(forKey: Key.notAskToReconnect)
    }
    
    @objc dynamic var resolvedDNSInsideVPN: [String] {
        return stringArray(forKey: Key.resolvedDNSInsideVPN) ?? [customDNS]
    }
    
    @objc dynamic var isIPv6: Bool {
        return bool(forKey: Key.isIPv6)
    }
    
    @objc dynamic var showIPv4Servers: Bool {
        return bool(forKey: Key.showIPv4Servers)
    }
    
    @objc dynamic var killSwitch: Bool {
        return bool(forKey: Key.killSwitch)
    }
    
    @objc dynamic var selectHost: Bool {
        return bool(forKey: Key.selectHost)
    }
    
    @objc dynamic var preventSameCountryMultiHop: Bool {
        return bool(forKey: Key.preventSameCountryMultiHop)
    }
    
    @objc dynamic var preventSameISPMultiHop: Bool {
        return bool(forKey: Key.preventSameISPMultiHop)
    }
    
    @objc dynamic var isLoggedIn: Bool {
        return bool(forKey: Key.isLoggedIn)
    }
    
    @objc dynamic var disableLanAccess: Bool {
        return bool(forKey: Key.disableLanAccess)
    }
    
    @objc dynamic var v2rayProtocol: String {
        return string(forKey: Key.v2rayProtocol) ?? "udp"
    }
    
    @objc dynamic var isV2ray: Bool {
        return bool(forKey: Key.isV2ray)
    }
    
    static func registerUserDefaults() {
        shared.register(defaults: [Key.networkProtectionUntrustedConnect: true])
        shared.register(defaults: [Key.networkProtectionTrustedDisconnect: true])
        shared.register(defaults: [Key.keepAlive: true])
        shared.register(defaults: [Key.wgRegenerationRate: Config.wgKeyRegenerationRate])
        shared.register(defaults: [Key.wgKeyTimestamp: Date()])
        shared.register(defaults: [Key.serversSort: "city"])
        standard.register(defaults: [Key.selectedServerFastest: true])
        standard.register(defaults: [Key.showIPv4Servers: true])
        standard.register(defaults: [Key.preventSameCountryMultiHop: true])
    }
    
    static func clearSession() {
        shared.removeObject(forKey: Key.isMultiHop)
        shared.removeObject(forKey: Key.isLogging)
        shared.removeObject(forKey: Key.networkProtectionEnabled)
        shared.removeObject(forKey: Key.networkProtectionUntrustedConnect)
        shared.removeObject(forKey: Key.networkProtectionTrustedDisconnect)
        shared.removeObject(forKey: Key.isCustomDNS)
        shared.removeObject(forKey: Key.customDNS)
        shared.removeObject(forKey: Key.customDNSProtocol)
        shared.removeObject(forKey: Key.resolvedDNSInsideVPN)
        shared.removeObject(forKey: Key.isAntiTracker)
        shared.removeObject(forKey: Key.isAntiTrackerHardcore)
        shared.removeObject(forKey: Key.wgKeyTimestamp)
        shared.removeObject(forKey: Key.wgRegenerationRate)
        shared.removeObject(forKey: Key.apiHostName)
        shared.removeObject(forKey: Key.sessionsLimit)
        shared.removeObject(forKey: Key.keepAlive)
        shared.removeObject(forKey: Key.notAskToReconnect)
        shared.removeObject(forKey: Key.isIPv6)
        shared.removeObject(forKey: Key.killSwitch)
        shared.removeObject(forKey: Key.selectHost)
        shared.removeObject(forKey: Key.isLoggedIn)
        shared.removeObject(forKey: Key.antiTrackerDns)
        shared.removeObject(forKey: Key.disableLanAccess)
        shared.removeObject(forKey: Key.v2raySettings)
        shared.removeObject(forKey: Key.v2rayProtocol)
        shared.removeObject(forKey: Key.isV2ray)
        standard.removeObject(forKey: Key.serviceStatus)
        standard.removeObject(forKey: Key.selectedHost)
        standard.removeObject(forKey: Key.selectedExitHost)
        standard.removeObject(forKey: Key.selectedServerFastest)
        standard.removeObject(forKey: Key.fastestServerConfigured)
        standard.removeObject(forKey: Key.showIPv4Servers)
        standard.removeObject(forKey: Key.selectedProtocol)
        standard.removeObject(forKey: Key.wgMtu)
        standard.removeObject(forKey: Key.preventSameCountryMultiHop)
        standard.removeObject(forKey: Key.preventSameISPMultiHop)
        standard.synchronize()
    }
    
}
