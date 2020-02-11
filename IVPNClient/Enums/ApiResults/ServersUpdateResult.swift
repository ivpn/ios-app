//
//  ServersUpdateResult.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/16/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import Foundation

enum ServersUpdateResult {
    case error
    case success(VPNServerList)
}
