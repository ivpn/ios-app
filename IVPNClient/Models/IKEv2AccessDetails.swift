//
//  VPNAccessDetails.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 11/8/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import Foundation

class AccessDetails {
    
    var serverAddress: String
    var username: String
    var passwordRef: Data?
    
    init(serverAddress: String, username: String, passwordRef: Data?) {
        self.serverAddress = serverAddress
        self.username = username
        self.passwordRef = passwordRef
    }
    
}
