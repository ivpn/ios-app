//
//  FileManager+Extension.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-11-30.
//  Copyright (c) 2022 IVPN Limited.
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
import os.log

extension FileManager {
    
    static var appGroupId: String {
        return Config.appGroup
    }
    
    private static var sharedFolderURL: URL? {
        guard let sharedFolderURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: FileManager.appGroupId) else {
            return nil
        }
        
        return sharedFolderURL
    }
    
    static var logFileURL: URL? {
        return sharedFolderURL?.appendingPathComponent("App.bin")
    }
    
    static var logTextFileURL: URL? {
        return sharedFolderURL?.appendingPathComponent("App.log")
    }
    
    static var wgLogFileURL: URL? {
        return sharedFolderURL?.appendingPathComponent("WireGuard.bin")
    }
    
    static var wgLogTextFileURL: URL? {
        return sharedFolderURL?.appendingPathComponent("WireGuard.log")
    }
    
    static var openvpnLogTextFileURL: URL? {
        return sharedFolderURL?.appendingPathComponent("Tunnel.log")
    }
    
    static func deleteFile(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            log(.error, message: error.localizedDescription)
            return false
        }
        return true
    }
    
}
