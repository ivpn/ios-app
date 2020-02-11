//
//  Application.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/17/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import Foundation

class Application {
    
    // MARK: - Properties -
    
    static var shared = Application()
    
    var authentication: Authentication
    var connectionManager: ConnectionManager
    
    var settings: Settings {
        didSet {
            connectionManager.settings = settings
        }
    }
    
    var serverList: VPNServerList {
        didSet {
            settings = Settings(serverList: serverList)
        }
    }
    
    var serviceStatus: ServiceStatus {
        didSet {
            serviceStatus.save()
        }
    }
    
    var network = Network(context: StorageManager.context, needToSave: false) {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.UpdateNetwork, object: nil)
        }
    }
    
    var showSubscriptionAction: Bool {
        if authentication.isLoggedIn &&
            (serviceStatus.isAppStoreSubscription() || !serviceStatus.isActive) {
            return true
        }
        
        return false
    }
    
    // MARK: - Initialize -
    
    private init() {
        serverList = VPNServerList()
        serviceStatus = ServiceStatus()
        authentication = Authentication()
        settings = Settings(serverList: serverList)
        connectionManager = ConnectionManager(settings: settings, authentication: authentication, vpnManager: VPNManager())
    }
    
}
