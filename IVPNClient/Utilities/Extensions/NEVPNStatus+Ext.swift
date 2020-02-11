//
//  NEVPNStatus+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 09/12/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import NetworkExtension

extension NEVPNStatus {
    
    func isDisconnected() -> Bool {
        return self == .disconnected || self == .invalid
    }
    
}
