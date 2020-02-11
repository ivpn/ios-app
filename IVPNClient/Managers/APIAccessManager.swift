//
//  APIAccessManager.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 06/08/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

class APIAccessManager {
    
    // MARK: - Properties -
    
    static let shared = APIAccessManager()
    
    private var hostNames: [String] {
        var hosts = hostNamesCollection
        hosts.move(UserDefaults.shared.apiHostName, to: 0)
        return hosts
    }
    
    private var hostNamesCollection: [String] {
        return [Config.ApiHostName] + UserDefaults.shared.hostNames
    }
    
    // MARK: - Methods -
    
    func nextHostName(failedHostName: String) -> String? {
        return hostNames.next(item: failedHostName)
    }
    
    func isHostIpAddress(host: String) -> Bool {
        do {
            let _ = try CIDRAddress(stringRepresentation: host)
            return true
        } catch {
            return false
        }
    }
    
}
