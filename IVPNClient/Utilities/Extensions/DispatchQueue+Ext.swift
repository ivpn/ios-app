//
//  DispatchQueue.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 28/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    static func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    static func async(closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
}
