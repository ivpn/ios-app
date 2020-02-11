//
//  ProductIdentifier.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

struct ProductIdentifier {
    
    static let standardYearly = "net.ivpn.autosubscriptions.standard.12month"
    static let standardMonthly = "net.ivpn.autosubscriptions.standard.1month"
    static let proYearly = "net.ivpn.autosubscriptions.12month"
    static let proMonthly = "net.ivpn.autosubscriptions.1month"
    
    static var all: Set<String> {
        return [standardYearly, standardMonthly, proYearly, proMonthly]
    }
    
}
