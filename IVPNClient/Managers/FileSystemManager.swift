//
//  FileSystemManager.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-10-14.
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

import UIKit

class FileSystemManager {
    
    private static let maxLogFileSize: UInt64 = 262144
    
    // Returns the URL to the application's Documents directory.
    static var applicationDocumentsDirectory: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1] as URL
    }
    
    static func pathToDocumentFile(_ fileName: String) -> URL {
        return applicationDocumentsDirectory.appendingPathComponent(fileName)
    }
    
    static func deleteDocumentFile(_ fileNameUrl: URL) {
        if FileManager.default.fileExists(atPath: fileNameUrl.path) == false {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: fileNameUrl)
        } catch {
            log(error: "There was an error deleting file URL \(fileNameUrl). Error: \(error)")
        }
    }
    
    static func loadDataFromResource(resourceName: String, resourceType: String, bundle: Bundle? = nil) -> Data? {
        let bundle = bundle ?? Bundle.main        
        let resource = bundle.path(forResource: resourceName, ofType: resourceType)
        
        guard resource != nil else {
            log(error: "Cannot read defaults file")
            return nil
        }
        
        return loadDataFromUrl(resource: URL(fileURLWithPath: resource!))
    }
    
    static func loadDataFromUrl(resource: URL) -> Data? {
        let data = try? Data(contentsOf: resource)
        
        guard data != nil else {
            log(error: "Cannot initialize data from the resource file: \(resource)")
            return nil
        }
        
        return data
    }
    
    static func clearSession() {
        resetLogFile(name: Config.openVPNLogFile)
    }
    
    // MARK: - App Group shared files -
    
    static func createSharedFile(name: String) {
        let file = sharedFilePath(name: name).path
        
        if !FileManager.default.fileExists(atPath: file) {
            FileManager.default.createFile(atPath: file, contents: nil, attributes: nil)
        } else {
            log(error: "File is already created")
        }
    }
    
    static func fileExists(name: String) -> Bool {
        let file = sharedFilePath(name: name).path
        
        return FileManager.default.fileExists(atPath: file)
    }
    
    static func appendToSharedFile(text: String, name: String) {
        let file = sharedFilePath(name: name)
        let textToWrite = text
        
        guard let data = textToWrite.data(using: String.Encoding.utf8) else { return }
        guard let fileHandle = FileHandle(forWritingAtPath: file.path) else { return }
        
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
    }
    
    static func writeToSharedFile(text: String, name: String) {
        let file = sharedFilePath(name: name)
        let textToWrite = text
        
        do {
            try textToWrite.write(to: file, atomically: false, encoding: String.Encoding.utf8)
        } catch let error {
            log(error: "Something went wrong: \(error)")
        }
    }
    
    static func deleteSharedFile(name: String) {
        let file = sharedFilePath(name: name)
        
        do {
            try FileManager.default.removeItem(atPath: file.path)
        } catch let error {
            log(error: "Something went wrong: \(error)")
        }
    }
    
    static func resetLogFile(name: String) {
        if !fileExists(name: name) {
            createSharedFile(name: name)
        }
        
        writeToSharedFile(text: "\(Date.logTime()) \(UIDevice.logInfo())\n", name: name)
    }
    
    static func updateLogFile(newestLog: String?, name: String, isLoggedIn: Bool) {
        guard isLoggedIn else {
            resetLogFile(name: name)
            return
        }
        
        guard let newestLog = newestLog else { return }
        
        resetLogFile(name: name)
        appendToSharedFile(text: newestLog, name: name)
    }
    
    static func createLogFiles() {
        if fileExists(name: Config.openVPNLogFile) {
            resetLogFile(name: Config.openVPNLogFile)
        }
    }
    
    // MARK: - Helper Methods -
    
    static func sharedFilePath(name: String) -> URL {
        guard let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Config.appGroup) else { return URL(fileURLWithPath: "") }
        
        return directory.appendingPathComponent(name)
    }
    
    private static func getFileSize(path: String) -> UInt64 {
        do {
            let fileSize = try (FileManager.default.attributesOfItem(atPath: path) as NSDictionary).fileSize()
            return fileSize
        } catch let error {
            log(error: "Something went wrong: \(error)")
            return 0
        }
    }
    
}
