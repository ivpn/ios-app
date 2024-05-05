//
//  PortRange.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-07-15.
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

struct PortRange {
    
    // MARK: - Properties -
    
    var tunnelType: String
    var protocolType: String
    var ranges: [CountableClosedRange<Int>]
    
    var portRangesText: String {
        let combinedRanges = PortRange.combinedIntervals(intervals: ranges.sorted { $0.lowerBound < $1.lowerBound })
        var textRanges = [String]()
        
        for range in combinedRanges {
            textRanges.append("\(String(describing: range.first ?? 0)) - \(String(describing: range.last ?? 0))")
        }
        
        return textRanges.joined(separator: ", ")
    }
    
    // MARK: - Methods -
    
    func validate(port: Int) -> String? {
        for range in ranges where range.contains(port) {
            return nil
        }
        
        return "Enter port number in the range: \(portRangesText)"
    }
    
    static func combinedIntervals(intervals: [CountableClosedRange<Int>]) -> [CountableClosedRange<Int>] {
        var combined = [CountableClosedRange<Int>]()
        var accumulator = (0...0) // empty range
        
        for interval in intervals.sorted(by: { $0.lowerBound  < $1.lowerBound  }) {
            if accumulator == (0...0) {
                accumulator = interval
            }
            
            if accumulator.upperBound >= interval.upperBound {
                // interval is already inside accumulator
            } else if accumulator.upperBound + 1 >= interval.lowerBound {
                // interval hangs off the back end of accumulator
                accumulator = (accumulator.lowerBound...interval.upperBound)
            } else if accumulator.upperBound <= interval.lowerBound {
                // interval does not overlap
                combined.append(accumulator)
                accumulator = interval
            }
        }
        
        if accumulator != (0...0) {
            combined.append(accumulator)
        }
        
        return combined
    }
    
}
