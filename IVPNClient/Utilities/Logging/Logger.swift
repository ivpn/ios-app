//
//  Logger.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-06.
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
import os.log

class Logger {
    
    enum LoggerError: Error {
        case openFailure
    }

    var logger: Logger?

    var log: OpaquePointer
    var tag: String

    init(tagged tag: String, withFilePath filePath: String) throws {
        guard let log = open_log(filePath) else {
            throw LoggerError.openFailure
        }
        
        self.log = log
        self.tag = tag
    }

    deinit {
        close_log(self.log)
    }

    func log(message: String) {
        write_msg_to_log(log, tag, message.trimmingCharacters(in: .newlines))
    }

    func writeLog(to targetFile: String) -> Bool {
        return write_log_to_file(targetFile, self.log) == 0
    }
    
}

struct SharedLogger {
    
    var app: Logger?
    var wireguard: Logger?
    
    init() {
        guard let logPath = FileManager.logFileURL?.path else {
            return
        }
        
        guard let wgLogPath = FileManager.wgLogFileURL?.path else {
            return
        }
        
        app = try? Logger(tagged: "App", withFilePath: logPath)
        wireguard = try? Logger(tagged: "WireGuard", withFilePath: wgLogPath)
    }
    
}

let logger = SharedLogger()

func log(_ type: OSLogType, message: String) {
    guard UserDefaults.shared.isLogging else {
        return
    }
    
    os_log("[INFO] %{public}s", log: OSLog.default, type: type, message)
    logger.app?.log(message: "\(message)")
}

func wg_log(_ type: OSLogType, message: String) {
    guard UserDefaults.shared.isLogging else {
        return
    }

    os_log("[INFO] %{public}s", log: OSLog.default, type: type, message)
    logger.wireguard?.log(message: "\(message)")
}

func log(info: String) {
    #if DEBUG
    print("[INFO] \(info)")
    #endif
    
    log(.info, message: info)
}

func log(error: String) {
    #if DEBUG
    print("[ERROR] \(error)")
    #endif
    
    log(.error, message: error)
}
