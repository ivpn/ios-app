//
//  AccountViewModel.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 24/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

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
    
    var statusColor: UIColor {
        return serviceStatus.isActive ? UIColor.init(named: Theme.ivpnGreen)! : UIColor.init(named: Theme.ivpnRedOff)!
    }
    
    var subscriptionText: String {
        return serviceStatus.isActive ? serviceStatus.currentPlan ?? "" : "No active subscription"
    }
    
    var activeUntilText: String {
        return serviceStatus.activeUntilString()
    }
    
    var logOutActionText: String {
        return authentication.isLoggedIn ? "Log Out" : "Log In or Sign Up"
    }
    
    var subscriptionActionText: String {
        return serviceStatus.isActive ? "Manage Subscription" : "Activate Subscription"
    }
    
    var showSubscriptionAction: Bool {
        if let paymentMethod = serviceStatus.paymentMethod, paymentMethod == "ivpniosiap" {
            return true
        }
        
        return false
    }
    
    // MARK: - Initialize -
    
    init(serviceStatus: ServiceStatus, authentication: Authentication) {
        self.serviceStatus = serviceStatus
        self.authentication = authentication
    }
    
}
