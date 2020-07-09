//
//  UIButton+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-03-23.
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

extension UIButton {
    
    func setupIcon(imageName: String) {
        setImage(UIImage.init(named: imageName), for: .normal)
        backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
        layer.cornerRadius = 21
        clipsToBounds = true
    }
    
    func set(title: String, subtitle: String) {
        // Applying the line break mode
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        var buttonText: NSString = "\(title)\n\(subtitle)" as NSString
        
        if subtitle.isEmpty {
            buttonText = "\(title)" as NSString
        }

        // Getting the range to separate the button title strings
        let newlineRange: NSRange = buttonText.range(of: "\n")

        // Getting both substrings
        var substring1 = title
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
