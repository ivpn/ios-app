//
//  Logging.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 10/6/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import Foundation

func log(info: @autoclosure () -> String) {
    #if DEBUG
    print("Info: \(info())")
    #endif
}

func log(error: @autoclosure () -> String) {
    #if DEBUG
    print("Error: \(error())")
    #endif
}
