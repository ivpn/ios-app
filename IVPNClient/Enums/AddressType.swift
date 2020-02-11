//
//  AddressType.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 22/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

enum AddressType {
    
    case IPv6
    case IPv4
    case other
    
    static func validateIpAddress(ipToValidate: String) -> AddressType {
        var sin = sockaddr_in()
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return .IPv4
        }
        
        var sin6 = sockaddr_in6()
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            return .IPv6
        }
        
        return .other
    }
    
}
