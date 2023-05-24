//
//  KeyChain.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-20.
//  Copyright (c) 2023 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import KeychainAccess

class KeyChain {
    
    private static let usernameKey = "username"
    private static let sessionTokenKey = "session_token"
    
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
    
    class var sessionToken: String? {
        get {
            return KeyChain.bundle[sessionTokenKey]
        }
        set {
            KeyChain.bundle[sessionTokenKey] = newValue
        }
    }
    
}
