//
//  CIDRAddress.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 22/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

struct CIDRAddress {
    
    var ipAddress: String
    var subnet: Int32
    var addressType: AddressType
    
    var subnetString: String {
        var bitMask: UInt32 = 0b11111111111111111111111111111111
        bitMask = bitMask << (32 - subnet)
        
        let first = UInt8(truncatingIfNeeded: bitMask >> 24)
        let second = UInt8(truncatingIfNeeded: bitMask >> 16 )
        let third = UInt8(truncatingIfNeeded: bitMask >> 8)
        let fourth = UInt8(truncatingIfNeeded: bitMask)
        
        return "\(first).\(second).\(third).\(fourth)"
    }
    
    var stringRepresentation: String {
        return "\(ipAddress)/\(subnet)"
    }
    
    init?(stringRepresentation: String) throws {
        let subnetString: String.SubSequence
        
        if let range = stringRepresentation.range(of: "/", options: .backwards, range: nil, locale: nil) {
            let ipString = stringRepresentation[..<range.lowerBound].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            ipAddress = String(ipString)
            subnetString = stringRepresentation[range.upperBound...]
        } else {
            let ipString = stringRepresentation
            ipAddress = String(ipString)
            subnetString = ""
        }
        
        let addressType = AddressType.validateIpAddress(ipToValidate: ipAddress)
        
        guard addressType == .IPv4 || addressType == .IPv6 else {
            throw CIDRAddressValidationError.invalidIP(ipAddress)
        }
        
        self.addressType = addressType
        
        if let subnet = Int32(subnetString) {
            switch addressType {
            case .IPv6:
                self.subnet = subnet > 128 ? 128 : subnet
            case .IPv4:
                self.subnet = subnet > 32 ? 32 : subnet
            case .other:
                self.subnet = subnet
            }
        } else {
            switch addressType {
            case .IPv4:
                subnet = 32
            case .IPv6:
                subnet = 128
            case .other:
                throw CIDRAddressValidationError.invalidSubnet(String(subnetString))
            }
        }
    }
    
}

extension CIDRAddress {
    
    enum CIDRAddressValidationError: Error {
        
        case noIpAndSubnet(String)
        case invalidIP(String)
        case invalidSubnet(String)
        
        var localizedDescription: String {
            switch self {
            case .noIpAndSubnet:
                return NSLocalizedString("CIDRAddressValidationError", comment: "Error message for malformed CIDR address.")
            case .invalidIP:
                return NSLocalizedString("CIDRAddressValidationError", comment: "Error message for invalid address ip.")
            case .invalidSubnet:
                return NSLocalizedString("CIDRAddressValidationError", comment: "Error message invalid address subnet.")
            }
        }
        
    }
    
}
