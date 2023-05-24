//
//  Authentication.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/9/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

//
//  Authentication.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-09.
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

// Authentication class is responsible for securely storing and retrieving of login credentials
// It does not perform any authentication and just managing the informatino supplied

class Authentication {
    
    // MARK: - Properties -
    
    var isLoggedIn: Bool {
        let username = getStoredUsername()
        let sessionToken = getStoredSessionToken()
        return !username.isEmpty || !sessionToken.isEmpty
    }
    
    // MARK: - Methods -
    
    func logIn(session: Session) {
        guard session.token != nil, session.vpnUsername != nil, session.vpnPassword != nil else {
            return
        }
        
        UserDefaults.shared.set(true, forKey: UserDefaults.Key.isLoggedIn)
        KeyChain.save(session: session)
    }
    
    func logOut(deleteSettings: Bool) {
        KeyChain.clearAll()
        FileSystemManager.clearSession()
        Application.shared.clearSession()
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.networkProtectionEnabled)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isLoggedIn)
        
        if deleteSettings {
            StorageManager.clearSession()
            UserDefaults.clearSession()
            Application.shared.settings.connectionProtocol = Config.defaultProtocol
            Application.shared.settings.saveConnectionProtocol()
        }
    }
    
    func removeStoredCredentials() {
        KeyChain.username = nil
        
        log(.info, message: "Credentials removed from Key Chain")
    }
    
    func getStoredUsername() -> String {
        return KeyChain.username ?? ""
    }
    
    func getStoredSessionToken() -> String {
        return KeyChain.sessionToken ?? ""
    }
    
}
