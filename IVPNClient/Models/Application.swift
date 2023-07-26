//
//  Application.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/17/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

//
//  Application.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-17.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
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
    
    var geoLookup = GeoLookup(ipAddress: "", countryCode: "", country: "", city: "", isIvpnServer: false, isp: "", latitude: 0, longitude: 0)
    
    static var isKeyPairRequired: Bool {
        return shared.settings.connectionProtocol.tunnelType() == .wireguard
    }
    
    // MARK: - Initialize -
    
    private init() {
        serverList = VPNServerList()
        serviceStatus = ServiceStatus()
        authentication = Authentication()
        settings = Settings(serverList: serverList)
        connectionManager = ConnectionManager(settings: settings, authentication: authentication, vpnManager: VPNManager())
    }
    
    // MARK: - Methods -
    
    func clearSession() {
        serviceStatus.isActive = false
    }
    
}
