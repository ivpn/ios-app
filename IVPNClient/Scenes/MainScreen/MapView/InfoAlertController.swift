//
//  InfoAlertController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 13/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class InfoAlertController {
    
    // MARK: - Properties -
    
    var text: String {
        let days = Application.shared.serviceStatus.daysUntilSubscriptionExpiration()
        switch infoAlert {
        case .trialPeriod:
            return "Trial period will expire in \(days) days"
        case .subscriptionExpiration:
            return "Subscription will expire in \(days) days"
        }
    }
    
    var actionText: String {
        switch infoAlert {
        case .trialPeriod:
            return "RENEW"
        case .subscriptionExpiration:
            return ""
        }
    }
    
    var type: InfoAlertViewType {
        switch infoAlert {
        case .trialPeriod:
            return .info
        case .subscriptionExpiration:
            return .alert
        }
    }
    
    var shouldDisplay: Bool {
        return Application.shared.serviceStatus.daysUntilSubscriptionExpiration() <= 3
    }
    
    private var infoAlert: InfoAlert = .subscriptionExpiration
    
    // MARK: - Methods -
    
    func update() {
        if Application.shared.serviceStatus.isOnFreeTrial && shouldDisplay {
            infoAlert = .trialPeriod
            return
        }
        
        if shouldDisplay {
            infoAlert = .subscriptionExpiration
        }
    }
    
}

// MARK: - InfoAlertController extension -

extension InfoAlertController {
    
    enum InfoAlert {
        case trialPeriod
        case subscriptionExpiration
    }
    
}

// MARK: - InfoAlertViewDelegate -

extension InfoAlertController: InfoAlertViewDelegate {
    
    func action() {
        switch infoAlert {
        case .trialPeriod:
            break
        case .subscriptionExpiration:
            if let topViewController = UIApplication.topViewController() {
                topViewController.manageSubscription()
            }
        }
    }
    
}
