//
//  PingResult.swift
//  PingTest
//
//  Created by wenyu on 2018/11/25.
//  Copyright © 2018年 wenyu. All rights reserved.
//

import UIKit

enum PingStatus{
    case pending
    case success
    case fail
}

class PingResult: NSObject {

    var sequenceNumber : UInt = 0
    var payloadSize : UInt = 0
    var ttl : UInt = 0
    var host : String?
    var sendDate : Date?
    var receiveDate : Date?{
        didSet{
            if let receiveDate = receiveDate?.timeIntervalSince1970,let sendDate = sendDate?.timeIntervalSince1970{
                time = receiveDate - sendDate
            }
        }
    }
    var time : TimeInterval = 0
    var rtt : TimeInterval{
        get{
            if let sendDate = sendDate{
                return receiveDate?.timeIntervalSince(sendDate) ?? 0
            }
            return 0
        }
    }
    var pingStatus = PingStatus.pending
    
    required override init() {
        super.init()
    }
    
    func copy() -> Self {
        let newResult = type(of: self).init()
        newResult.sequenceNumber = sequenceNumber
        newResult.payloadSize = payloadSize
        newResult.ttl = ttl
        newResult.host = host
        newResult.sendDate = sendDate
        newResult.receiveDate = receiveDate
        newResult.time = time
        newResult.pingStatus = pingStatus
        return newResult
    }
}
