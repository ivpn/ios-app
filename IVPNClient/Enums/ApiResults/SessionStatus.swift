//
//  SessionStatus.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 03/09/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct SessionStatus: Decodable {
    let status: Int
    let serviceStatus: ServiceStatus
    
    var serviceActive: Bool {
        return status == 200 && serviceStatus.isActive
    }
    
    var serviceExpired: Bool {
        return status == 200 && !serviceStatus.isActive
    }
}
