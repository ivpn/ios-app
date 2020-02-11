//
//  ApiServiceResult.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 08/08/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

enum Result<T: Decodable> {
    case success(T)
    case failure(Error?)
}

enum ResultCustomError<T: Decodable, E: Decodable> {
    case success(T)
    case failure(E?)
}
