//
//  VPNServerViewModel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 28/01/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit

struct VPNServerViewModel {
    
    // MARK: - Properties -
    
    var server: VPNServer
    
    var imageForPingTimeForMainScreen: UIImage? {
        if server.pingMs == nil { return nil }
        return UIImage(named: imageNameForPingTime)
    }
    
    var formattedServerNameForMainScreen: String {
        if server.fastestServerLabelShouldBePresented { return "Fastest server" }
        return formattedServerName
    }
    
    var imageForCountryCodeForMainScreen: UIImage? {
        if server.fastestServerLabelShouldBePresented {
            let image = UIImage(named: "icon-fastest-server")
            image?.accessibilityIdentifier = "icon-fastest-server"
            return image
        }
        return UIImage(named: server.countryCode.lowercased() + "-v")
    }
    
    var formattedServerNameForSettings: String {
        if server.fastest { return "Fastest server" }
        return formattedServerName
    }
    
    var imageForCountryCodeForSettings: UIImage? {
        if server.fastest {
            let image = UIImage(named: "icon-fastest-server")
            image?.accessibilityIdentifier = "icon-fastest-server"
            return image
        }
        return UIImage(named: server.countryCode.lowercased() + "-v")
    }
    
    var imageNameForPingTime: String {
        guard let pingMs = server.pingMs else { return "" }
        if pingMs >= 0 && pingMs < 100 { return "icon-circle-green" }
        if pingMs >= 100 && pingMs < 300 { return "icon-circle-orange" }
        return "icon-circle-red"
    }
    
    var formattedServerName: String {
        return "\(server.city), \(server.countryCode.uppercased())"
    }
    
    var formattedServerLocation: String {
        return "\(server.city), \(server.country)"
    }
    
    var imageForCountryCode: UIImage? {
        return UIImage(named: server.countryCode.lowercased() + "-v")
    }
    
    var imageNameForCountryCode: String {
        return server.countryCode.lowercased() + "-v"
    }
    
    var imageForPingTime: UIImage? {
        if server.pingMs == nil { return nil }
        return UIImage(named: imageNameForPingTime)
    }
    
    // MARK: - Initialize -
    
    init(server: VPNServer) {
        self.server = server
    }
    
}
