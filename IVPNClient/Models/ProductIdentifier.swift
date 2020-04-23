//
//  ProductIdentifier.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct ProductIdentifier {
    
    static let standardMonthly = "net.ivpn.subscriptions.standard.month"
    static let standardYearly = "net.ivpn.subscriptions.standard.year"
    static let proMonthly = "net.ivpn.subscriptions.pro.month"
    static let proYearly = "net.ivpn.subscriptions.pro.year"
    
    static var all: Set<String> {
        return [standardYearly, standardMonthly, proYearly, proMonthly]
    }
    
}
