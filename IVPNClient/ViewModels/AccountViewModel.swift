//
//  AccountViewModel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 24/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import Foundation

struct AccountViewModel {
    
    // MARK: - Properties -
    
    var serviceStatus: ServiceStatus
    var authentication: Authentication
    
    var accountId: String {
        return authentication.getStoredUsername()
    }
    
    var statusText: String {
        return serviceStatus.isActive ? "ACTIVE" : "INACTIVE"
    }
    
    // MARK: - Initialize -
    
    init(serviceStatus: ServiceStatus, authentication: Authentication) {
        self.serviceStatus = serviceStatus
        self.authentication = authentication
    }
    
}
