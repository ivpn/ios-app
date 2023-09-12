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
    private let configFile = "config.json"
    
    // MARK: - Methods -
    
    func start(completion: ((_ error: Error?) -> Void)?) {
        var startError: Error? = nil
        
        if let core = core {
            do {
                try core.close()
                self.core = nil
            } catch let error {
                startError = error
            }
        }
        
        var configError: NSError?
        let coreConfig = CoreLoadConfigFromJsonFile(configFile, &configError)
        if configError != nil {
            startError = configError as Error?
            completion?(startError)
            return
        }
        
        do {
            var initError: NSError?
            core = CoreNew(coreConfig, &initError)
            if initError != nil {
                startError = initError as Error?
            }
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
