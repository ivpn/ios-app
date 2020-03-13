//
//  InfoAlertController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 13/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import Foundation

class InfoAlertController {
    
    // MARK: - Properties -
    
    var text: String {
        return ""
    }
    
    var actionText: String {
        return ""
    }
    
    var type: InfoAlertViewType {
        return .info
    }
    
    private var infoAlert: InfoAlert = .trialPerion
    
    // MARK: - Methods -
    
    func updateInfoAlert() {
        // TODO: Update infoAlert property based on subscription status
    }
    
}

// MARK: - InfoAlertController extension -

extension InfoAlertController {
    
    enum InfoAlert {
        case trialPerion
        case subscriptionExpiration
    }
    
}

// MARK: - InfoAlertViewDelegate -

extension InfoAlertController: InfoAlertViewDelegate {
    
    func action() {
        // TODO: Handle action based on InfoAlert
    }
    
}
