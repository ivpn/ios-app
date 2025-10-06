//
//  KeyChain.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-11-08.
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
import KeychainAccess

class KeyChain {
    
    private static let usernameKey = "username"
    private static let tempUsernameKey = "tempUsernameKey"
    private static let wgPublicKeyKey = "WGPublicKey"
    private static let wgPrivateKeyKey = "WGPrivateKey"
    private static let wgIpAddressKey = "WGIpAddressKey"
    private static let wgIpv6HostKey = "WGIPv6HostKey"
    private static let wgIpAddressesKey = "WGIpAddressesKey"
    private static let wgPresharedKeyKey = "WGPresharedKey"
    private static let sessionTokenKey = "session_token"
    private static let vpnUsernameKey = "vpn_username"
    private static let vpnPasswordKey = "vpn_password"
    private static let deviceNameKey = "deviceName"
    
    static let bundle: Keychain = {
        return Keychain(service: "net.ivpn.clients.ios", accessGroup: "WQXXM75BYN.net.ivpn.IVPN-Client").accessibility(.whenPasscodeSetThisDeviceOnly)
    }()
    
    class var username: String? {
        get {
            return KeyChain.bundle[usernameKey]
        }
        set {
            KeyChain.bundle[usernameKey] = newValue
        }
    }
    
    class var tempUsername: String? {
        get {
            return KeyChain.bundle[tempUsernameKey]
        }
        set {
            KeyChain.bundle[tempUsernameKey] = newValue
        }
    }
    
    class var wgPublicKey: String? {
        get {
            return KeyChain.bundle[wgPublicKeyKey]
        }
        set {
            KeyChain.bundle[wgPublicKeyKey] = newValue
        }
    }
    
    class var wgPrivateKey: String? {
        get {
            return KeyChain.bundle[wgPrivateKeyKey]
        }
        set {
            KeyChain.bundle[wgPrivateKeyKey] = newValue
        }
    }
    
    class var wgIpAddress: String? {
        get {
            return KeyChain.bundle[wgIpAddressKey]
        }
        set {
            KeyChain.bundle[wgIpAddressKey] = newValue
        }
    }
    
    class var wgIpAddresses: String? {
        get {
            return KeyChain.bundle[wgIpAddressesKey]
        }
        set {
            KeyChain.bundle[wgIpAddressesKey] = newValue
        }
    }
    
    class var wgPresharedKey: String? {
        get {
            return KeyChain.bundle[wgPresharedKeyKey]
        }
        set {
            KeyChain.bundle[wgPresharedKeyKey] = newValue
        }
    }
    
    class var wgIpv6Host: String? {
        get {
            return KeyChain.bundle[wgIpv6HostKey]
        }
        set {
            KeyChain.bundle[wgIpv6HostKey] = newValue
        }
    }
    
    class var sessionToken: String? {
        get {
            return KeyChain.bundle[sessionTokenKey]
        }
        set {
            KeyChain.bundle[sessionTokenKey] = newValue
        }
    }
    
    class var vpnUsername: String? {
        get {
            return KeyChain.bundle[vpnUsernameKey]
        }
        set {
            KeyChain.bundle[vpnUsernameKey] = newValue
        }
    }
    
    class var vpnPassword: String? {
        get {
            return KeyChain.bundle[vpnPasswordKey]
        }
        set {
            KeyChain.bundle[vpnPasswordKey] = newValue
        }
    }
    
    class var vpnPasswordRef: Data? {
        return KeyChain.bundle[attributes: vpnPasswordKey]?.persistentRef
    }
    
    static func save(session: Session) {
        sessionToken = session.token
        vpnUsername = session.vpnUsername
        vpnPassword = session.vpnPassword
        deviceName = session.deviceName
        
        if let wireguardResult = session.wireguard, let ipAddress = wireguardResult.ipAddress {
            KeyChain.wgIpAddress = ipAddress
        }
    }
    
    class var deviceName: String? {
        get {
            return KeyChain.bundle[deviceNameKey]
        }
        set {
            KeyChain.bundle[deviceNameKey] = newValue
        }
    }
    
    static func clearAll() {
        username = nil
        tempUsername = nil
        wgPrivateKey = nil
        wgPublicKey = nil
        wgIpAddress = nil
        wgIpAddresses = nil
        wgPresharedKey = nil
        sessionToken = nil
        vpnUsername = nil
        vpnPassword = nil
        deviceName = nil
    }
    
}
