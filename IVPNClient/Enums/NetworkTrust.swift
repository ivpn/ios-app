//
//  NetworkTrust.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 21/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
enum NetworkTrust: String, CaseIterable {
    
    case Trusted
    case Untrusted
    case Default
    case None
    
    static var allCasesNormal: [NetworkTrust] {
        return NetworkTrust.allCases.filter { $0 != .None }
    }
    
    static var allCasesDefault: [NetworkTrust] {
        return NetworkTrust.allCases.filter { $0 != .Default }
    }
    
}
// swiftlint:enable identifier_name
