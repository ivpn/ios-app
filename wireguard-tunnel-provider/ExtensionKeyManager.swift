//
//  ExtensionKeyManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-03-08.
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

struct ExtensionKeyManager {
    
    static let shared = ExtensionKeyManager()
    
    static var regenerationCheckInterval: TimeInterval {
        if Config.useDebugWireGuardKeyUpgrade {
            return TimeInterval(10)
        }
        
        return TimeInterval(60 * 60)
    }
    
    static var regenerationInterval: TimeInterval {
        var regenerationRate = UserDefaults.shared.wgRegenerationRate
        
        if regenerationRate <= 0 {
            regenerationRate = 1
        }
        
        if Config.useDebugWireGuardKeyUpgrade {
            return TimeInterval(regenerationRate * 60)
        }
        
        return TimeInterval(regenerationRate * 60 * 60 * 24)
    }
    
    func upgradeKey(completion: @escaping (String?, String?) -> Void) {
        guard ExtensionKeyManager.needToRegenerate() else {
            completion(nil, nil)
            return
        }
        
        var interface = Interface()
        interface.privateKey = Interface.generatePrivateKey()
        
        let params = ApiManager.authParams + [
            URLQueryItem(name: "connected_public_key", value: KeyChain.wgPublicKey ?? ""),
            URLQueryItem(name: "public_key", value: interface.publicKey ?? "")
        ]
        
        let request = ApiRequestDI(method: .post, endpoint: Config.apiSessionWGKeySet, params: params)
        
        ApiManager.shared.request(request) { (result: Result<InterfaceResult>) in
            switch result {
            case .success(let model):
                UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.wgKeyTimestamp)
                KeyChain.wgPrivateKey = interface.privateKey
                KeyChain.wgPublicKey = interface.publicKey
                KeyChain.wgIpAddress = model.ipAddress
                completion(interface.privateKey, model.ipAddress)
            case .failure:
                completion(nil, nil)
            }
        }
    }
    
    static func needToRegenerate() -> Bool {
        guard KeyChain.wgPublicKey != nil else { return false }
        guard Date() > UserDefaults.shared.wgKeyTimestamp.addingTimeInterval(ExtensionKeyManager.regenerationInterval) else { return false }
        
        return true
    }
    
}
