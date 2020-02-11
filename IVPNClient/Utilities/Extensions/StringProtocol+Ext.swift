//
//  StringProtocol+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 11/06/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

extension StringProtocol where Index == String.Index {
    
    func substring(from start: String, to end: String? = nil, options: String.CompareOptions = []) -> SubSequence? {
        guard let lower = range(of: start, options: options)?.upperBound else { return nil }
        guard let end = end else { return self[lower...] }
        guard let upper = self[lower...].range(of: end, options: options)?.lowerBound else { return nil }
        return self[lower..<upper]
    }
    
}
