//
//  Array.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 28/09/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    func next(item: Element) -> Element? {
        if let index = self.firstIndex(of: item), index + 1 <= self.count {
            return index + 1 == self.count ? nil : self[index + 1]
        }
        return nil
    }
    
    mutating func move(_ item: Element, to newIndex: Index) {
        if let index = firstIndex(of: item) {
            move(at: index, to: newIndex)
        }
    }
    
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
    
}
