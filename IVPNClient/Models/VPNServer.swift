//
//  VPNServer.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/16/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import Foundation
import NetworkExtension

class VPNServer {
    
    // MARK: - Properties -
    
    var pingMs: Int?
    var pingRelative: Double?
    var status: NEVPNStatus = .invalid {
        didSet {
            UserDefaults.standard.set(status.rawValue, forKey: "SelectedServerStatus")
            UserDefaults.standard.synchronize()
        }
    }
    
    var fastest = false {
        didSet {
            UserDefaults.standard.set(fastest, forKey: "SelectedServerFastest")
            UserDefaults.standard.synchronize()
        }
    }
    
    var fastestServerLabelShouldBePresented: Bool {
        if fastest && pingMs == nil && status != .connected {
            return true
        }
        return false
    }
    
    private (set) var gateway: String
    private (set) var countryCode: String
    private (set) var country: String
    private (set) var city: String
    private (set) var ipAddresses: [String]
    private (set) var hosts: [Host]
    
    // MARK: - Initialize -
    
    init(gateway: String, countryCode: String, country: String, city: String, ipAddresses: [String] = [], hosts: [Host] = [], fastest: Bool = false) {
        self.gateway = gateway
        self.countryCode = countryCode
        self.country = country
        self.city = city
        self.ipAddresses = ipAddresses
        self.hosts = hosts
        self.fastest = fastest
    }
    
    // MARK: - Methods -
    
    func getLocationFromGateway() -> String {
        let gatewayParts = gateway.components(separatedBy: ".")
        if let location = gatewayParts.first { return location }
        return ""
    }
    
    static func == (lhs: VPNServer, rhs: VPNServer) -> Bool {
        return lhs.city == rhs.city && lhs.countryCode == rhs.countryCode
    }

}
