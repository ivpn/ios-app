//
//  Authentication.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/9/16.
//  Copyright © 2016 IVPN. All rights reserved.
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
    
    var hasSignupCredentials: Bool {
        let email = KeyChain.email ?? ""
        let password = KeyChain.password ?? ""
        return !email.isEmpty && !password.isEmpty
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
