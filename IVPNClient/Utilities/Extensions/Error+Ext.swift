//
//  Error+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
