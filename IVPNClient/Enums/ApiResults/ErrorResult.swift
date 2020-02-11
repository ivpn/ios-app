//
//  ErrorResponse.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct ErrorResult: Decodable {
    let status: Int
    let message: String
}
