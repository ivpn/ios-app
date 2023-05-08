//
//  UIDevice+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-10-01.
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
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import LocalAuthentication

extension UIDevice {
    
    static func uuidString() -> String {
        guard let identifierForVendor = current.identifierForVendor else { return "" }
        return identifierForVendor.uuidString
    }
    
    static func logInfo() -> String {
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let modelName = UIDevice.modelName
        var versionNumber = ""
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber = "IVPN \(version)"
        }
        
        return "\(versionNumber) | \(modelName) | \(systemName) \(systemVersion)"
    }
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // swiftlint:disable cyclomatic_complexity
        func mapToDevice(identifier: String) -> String {
            switch identifier {
            case "iPod5,1":                                  return "iPod Touch 5"
            case "iPod7,1":                                  return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":      return "iPhone 4"
            case "iPhone4,1":                                return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                   return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                   return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                   return "iPhone 5s"
            case "iPhone7,2":                                return "iPhone 6"
            case "iPhone7,1":                                return "iPhone 6 Plus"
            case "iPhone8,1":                                return "iPhone 6s"
            case "iPhone8,2":                                return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                   return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                   return "iPhone 7 Plus"
            case "iPhone8,4":                                return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                 return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                 return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                 return "iPhone X"
            case "iPhone11,2":                               return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                 return "iPhone XS Max"
            case "iPhone11,8":                               return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":            return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":            return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":            return "iPad Air"
            case "iPad5,3", "iPad5,4":                       return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                     return "iPad 5"
            case "iPad7,5", "iPad7,6":                       return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":            return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":            return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":            return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                       return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                       return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                       return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                       return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                       return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                               return "Apple TV"
            case "AppleTV6,2":                               return "Apple TV 4K"
            case "AudioAccessory1,1":                        return "HomePod"
            case "i386", "x86_64":                           return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                         return identifier
            }
        }
        // swiftlint:enable cyclomatic_complexity
        
        return mapToDevice(identifier: identifier)
    }()
    
    static func screenHeightLargerThan(device: ScreenHeight) -> Bool {
        guard UIScreen.main.nativeBounds.height > device.rawValue else { return false }
        return true
    }
    
    static func screenHeightSmallerThan(device: ScreenHeight) -> Bool {
        guard UIScreen.main.nativeBounds.height < device.rawValue else { return false }
        return true
    }
    
    static func fetchWiFiSSID(completion: @escaping (String?) -> Void) {
        NEHotspotNetwork.fetchCurrent { network in
            completion(network?.ssid)
        }
    }
    
    static func isPasscodeSet() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
}

extension UIDevice {
    
    enum ScreenHeight: CGFloat {
        case iPhones44S = 960
        case iPhones55s5cSE = 1136
        case iPhones66s78 = 1334
        case iPhoneXR = 1792
        case iPhones6Plus6sPlus7Plus8Plus = 1920
        case iPhonesXXS = 2436
        case iPhoneXSMax = 2688
    }
    
}
