//
//  WireGuardKeyResult.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 30/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

enum WireGuardKeyResult {
    case serviceError(Error?)
    case success(Interface)
}
