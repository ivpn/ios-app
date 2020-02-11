//
//  SuccessResult.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 06/09/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct SuccessResult: Decodable {
    let status: Int
    let message: String?
    
    var statusOK: Bool {
        return status == 200
    }
}
