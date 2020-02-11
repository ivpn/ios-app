//
//  ICMPHeader.swift
//  ThreeTab
//
//  Created by wenyu on 2018/11/17.
//  Copyright © 2018年 ThreeTab. All rights reserved.
//
import Darwin

struct IPHeader {
    var versionAndHeaderLength : UInt8
    var differentiatedServices : UInt8
    var totalLength : UInt16
    var identification : UInt16
    var flagsAndFragmentOffset : UInt16
    var timeToLive : UInt8
    var ptl : UInt8
    var headerChecksum: UInt16
    var sourceAddress : (UInt8,UInt8,UInt8,UInt8)
    var destinationAddress : (UInt8,UInt8,UInt8,UInt8)
}



// ICMP header structure:

struct ICMPHeader {
    var type : UInt8
    var code : UInt8
    var checksum : UInt16
    var identifier : UInt16
    var sequenceNumber : UInt16
    // data...
}


func in_cksum(_ buffer:UnsafeRawPointer, _ bufferLen:size_t) -> UInt16
    // This is the standard BSD checksum code, modified to use modern types.
{
    var bytesLeft : size_t
    var sum : UInt32
    var cursor = buffer.bindMemory(to: UInt16.self, capacity: bufferLen)
    var answer : UInt16
    
    bytesLeft = bufferLen
    sum = 0
    
    
    /*
     * Our algorithm is simple, using a 32 bit accumulator (sum), we add
     * sequential 16 bit words to it, and at the end, fold back all the
     * carry bits from the top 16 bits into the lower 16 bits.
     */
    while bytesLeft > 1 {
        sum += UInt32(cursor.pointee)
        cursor += 1
        bytesLeft -= 2;
    }
    

    /* mop up an odd byte, if necessary */
    if bytesLeft == 1{
        var uc = withUnsafePointer(to: cursor) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: cursor.pointee)) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout.size(ofValue: cursor.pointee)))
            }
        }
        if uc.count > 2{
            uc.removeLast(uc.count - 2)
            uc[1] = 0
        }
        let us = UnsafeRawPointer(uc).bindMemory(to: UInt16.self, capacity: MemoryLayout<UInt16>.size).pointee
        
        sum += UInt32(us)
    }
    
    /* add back carry outs from top 16 bits to low 16 bits */
    sum = (sum >> 16) + (sum & 0xffff)   /* add hi 16 to low 16 */
    sum += (sum >> 16)          /* add carry */
    answer = UInt16(truncatingIfNeeded: ~sum)  /* truncate to 16 bits */
    
    return answer;
}


