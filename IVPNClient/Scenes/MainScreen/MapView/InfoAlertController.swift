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
        switch infoAlert {
        case .trialPeriod:
            return "Trial period will expire in {n} days"
        case .subscriptionExpiration:
            return "Subscription will expire in {n} days"
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
    
    private var infoAlert: InfoAlert = .trialPeriod
    
    // MARK: - Methods -
    
    func updateInfoAlert() {
        // TODO: Update infoAlert property based on subscription status
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
