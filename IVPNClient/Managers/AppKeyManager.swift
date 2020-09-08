//
//  AppKeyManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-30.
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

@objc protocol AppKeyManagerDelegate: class {
    func setKeyStart()
    func setKeySuccess()
    func setKeyFail()
}

class AppKeyManager {
    
    // MARK: - Properties -
    
    weak var delegate: AppKeyManagerDelegate?
    
    static var keyTimestamp: Date {
        return UserDefaults.shared.wgKeyTimestamp
    }
    
    static var keyExpirationTimestamp: Date {
        if Config.useDebugWireGuardKeyUpgrade {
            return keyTimestamp.changeMinutes(by: Config.wgKeyExpirationDays)
        }
        
        return keyTimestamp.changeDays(by: Config.wgKeyExpirationDays)
    }
    
    static var keyRegenerationTimestamp: Date {
        let regenerationRate = UserDefaults.shared.wgRegenerationRate
        
        if Config.useDebugWireGuardKeyUpgrade {
            return keyTimestamp.changeMinutes(by: regenerationRate)
        }
        
        let regenerationDate = keyTimestamp.changeDays(by: regenerationRate)
        
        guard regenerationDate > Date() else {
            return Date()
        }
        
        return regenerationDate
    }
    
    static var isKeyExpired: Bool {
        guard KeyChain.wgPublicKey != nil else { return false }
        guard Date() > keyExpirationTimestamp else { return false }
        
        return true
    }
    
    static var isKeyPairRequired: Bool {
        return Application.shared.settings.connectionProtocol.tunnelType() == .wireguard
    }
    
    // MARK: - Methods -
    
    static func generateKeyPair() {
        var interface = Interface()
        interface.privateKey = Interface.generatePrivateKey()
        
        KeyChain.wgPrivateKey = interface.privateKey
        KeyChain.wgPublicKey = interface.publicKey
    }
    
    func setNewKey() {
        var interface = Interface()
        interface.privateKey = Interface.generatePrivateKey()
        
        let params = ApiService.authParams + [
            URLQueryItem(name: "public_key", value: interface.publicKey ?? "")
        ]
        
        let request = ApiRequestDI(method: .post, endpoint: Config.apiSessionWGKeySet, params: params)
        
        delegate?.setKeyStart()
        
        ApiService.shared.request(request) { (result: Result<InterfaceResult>) in
            switch result {
            case .success(let model):
                UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
                KeyChain.wgPrivateKey = interface.privateKey
                KeyChain.wgPublicKey = interface.publicKey
                KeyChain.wgIpAddress = model.ipAddress
                self.delegate?.setKeySuccess()
            case .failure:
                self.delegate?.setKeyFail()
            }
        }
    }
    
}
