//
//  Host.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 22/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

struct Host {
    
    var host: String
    var publicKey: String
    var localIP: String
    
    func localIPAddress() -> String {
        if let range = localIP.range(of: "/", options: .backwards, range: nil, locale: nil) {
            let ipString = localIP[..<range.lowerBound]
            return String(ipString)
        }
        
        return ""
    }
    
}
