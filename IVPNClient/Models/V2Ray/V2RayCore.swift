//
//  V2RayCore.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-08-23.
//  Copyright (c) 2023 IVPN Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import V2Ray

class V2RayCore {
    
    // MARK: - Properties -
    
    static let shared = V2RayCore()
    private var core: CoreInstance?
    
    // MARK: - Methods -
    
    func start(completion: ((_ error: Error?) -> Void)?) {
        if core != nil {
            try? core?.close()
            core = nil
        }
        
        let config = V2RayConfig.parse(fromJsonFile: "config")!
        let configData = try? JSONEncoder().encode(config)
        var startError: Error? = nil
        
        do {
            let config = CoreConfig.init()
            try config.xxX_Marshal(configData, deterministic: true)
            core = CoreNew(config, nil)
            try core?.start()
        } catch let error {
            startError = error
        }
        
        completion?(startError)
    }
    
    func close() {
        guard core != nil else {
            return
        }
        
        try? core?.close()
    }
    
}
