//
//  UIButton+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 05/05/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

extension UIButton {
    
    func set(title: String, subtitle: String) {
        // Applying the line break mode
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        let buttonText: NSString = "\(title)\n\(subtitle)" as NSString

        // Getting the range to separate the button title strings
        let newlineRange: NSRange = buttonText.range(of: "\n")

        // Getting both substrings
        var substring1 = ""
        var substring2 = ""

        if newlineRange.location != NSNotFound {
            substring1 = buttonText.substring(to: newlineRange.location)
            substring2 = buttonText.substring(from: newlineRange.location)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // Assigning diffrent fonts to both substrings
        let font1: UIFont = UIFont.systemFont(ofSize: 16)
        let attributes1 = [NSMutableAttributedString.Key.font: font1, NSMutableAttributedString.Key.paragraphStyle: paragraphStyle]
        let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes1)

        let font2: UIFont = UIFont.systemFont(ofSize: 12)
        let attributes2 = [NSMutableAttributedString.Key.font: font2, NSMutableAttributedString.Key.paragraphStyle: paragraphStyle]
        let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes2)

        // Appending both attributed strings
        attrString1.append(attrString2)

        // Assigning the resultant attributed strings to the button
        self.setAttributedTitle(attrString1, for: [])
    }
    
}
