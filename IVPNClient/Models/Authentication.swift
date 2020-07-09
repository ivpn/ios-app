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
    
    var isNewStyleAccount: Bool {
        let username = getStoredUsername()
        return ServiceStatus.isNewStyleAccount(username: username)
    }
    
    private(set) var randomPart: String
    private let accountRandomPartKey = "AccountRandomPart"
    
    // MARK: - Initialize -
    
    init() {
        if let randomPartFromSettings = UserDefaults.standard.string(forKey: accountRandomPartKey) {
            randomPart = randomPartFromSettings
        } else {
            randomPart = Authentication.randomString(length: 4)
            UserDefaults.standard.set(randomPart, forKey: accountRandomPartKey)
        }
    }
    
    // MARK: - Methods -
    
    private static func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyz"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func logIn(session: Session) {
        guard session.token != nil, session.vpnUsername != nil, session.vpnPassword != nil else { return }
        
        KeyChain.save(session: session)
        saveRandomPart()
    }
    
    func logOut() {
        KeyChain.clearAll()
        FileSystemManager.clearSession()
        StorageManager.clearSession()
        UserDefaults.clearSession()
        Application.shared.clearSession()
    }
    
    func removeStoredCredentials() {
        KeyChain.username = nil
        
        log(info: "Credentials removed from Key Chain")
    }
    
    func getStoredUsername() -> String {
        log(info: "Username read from Key Chain")
        
        return KeyChain.username ?? ""
    }
    
    func getStoredSessionToken() -> String {
        log(info: "Session token read from Key Chain")
        
        return KeyChain.sessionToken ?? ""
    }
    
    private func saveRandomPart() {
        randomPart = Authentication.randomString(length: 4)
        UserDefaults.standard.set(randomPart, forKey: accountRandomPartKey)
    }
    
}
