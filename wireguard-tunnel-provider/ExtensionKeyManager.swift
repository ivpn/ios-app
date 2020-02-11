//
//  ExtensionKeyManager.swift
//  wireguard-tunnel-provider
//
//  Created by Juraj Hilje on 08/03/2019.
//  Copyright © 2019 IVPN. All rights reserved.
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
        if Config.useDebugWireGuardKeyUpgrade {
            return TimeInterval(UserDefaults.shared.wgRegenerationRate * 60)
        }
        
        return TimeInterval(UserDefaults.shared.wgRegenerationRate * 60 * 60 * 24)
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
