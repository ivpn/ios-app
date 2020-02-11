//
//  Data+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 03/09/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import Foundation

extension Data {
    
    func withUnsafeUInt8Bytes<R>(_ body: (UnsafePointer<UInt8>) -> R) -> R {
        return self.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> R in
            let bytes = ptr.bindMemory(to: UInt8.self)
            return body(bytes.baseAddress!) // might crash if self.count == 0
        }
    }
    
    mutating func withUnsafeMutableUInt8Bytes<R>(_ body: (UnsafeMutablePointer<UInt8>) -> R) -> R {
        return self.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) -> R in
            let bytes = ptr.bindMemory(to: UInt8.self)
            return body(bytes.baseAddress!) // might crash if self.count == 0
        }
    }
    
    mutating func withUnsafeMutableInt8Bytes<R>(_ body: (UnsafeMutablePointer<Int8>) -> R) -> R {
        return self.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) -> R in
            let bytes = ptr.bindMemory(to: Int8.self)
            return body(bytes.baseAddress!) // might crash if self.count == 0
        }
    }
    
}
