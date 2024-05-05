//
//  IKEv2AccessDetails.swift
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

class AccessDetails {
    
    var ipAddress: String
    var gateway: String
    var username: String
    var passwordRef: Data?
    
    init(ipAddress: String, gateway: String, username: String, passwordRef: Data?) {
        self.ipAddress = ipAddress
        self.gateway = gateway
        self.username = username
        self.passwordRef = passwordRef
    }
    
}
