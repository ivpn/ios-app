//
//  NSMutableAttributedString.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 04/10/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    @discardableResult func bold(_ text: String, fontSize: CGFloat = 28) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold)]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func regular(_ text: String, fontSize: CGFloat = 28) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)]
        let normalString = NSMutableAttributedString(string: text, attributes: attrs)
        append(normalString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String, fontSize: CGFloat = 28) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.light)]
        let normalString = NSMutableAttributedString(string: text, attributes: attrs)
        append(normalString)
        
        return self
    }
    
}
