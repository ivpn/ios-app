//
//  UILabel+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-11-28.
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

extension UILabel {
    
    func icon(text textString: String, imageName: String, alignment: Alignment = .right) {
        guard !imageName.isEmpty else {
            self.text = textString
            return
        }
        
        let image = UIImage(named: imageName)
        guard image != nil else {
            self.text = textString
            return
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        let imageSize = attachment.image!.size
        attachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        let imageString = NSAttributedString(attachment: attachment)
        var text = NSAttributedString(string: textString + "  ")
        
        if alignment == .left {
            text = NSAttributedString(string: "  " + textString)
        }
        
        var attributedText = NSMutableAttributedString(attributedString: text)
        attributedText.append(imageString)
        
        if alignment == .left {
            attributedText = NSMutableAttributedString(attributedString: imageString)
            attributedText.append(text)
        }
        
        self.attributedText = attributedText
    }
    
    func iconMirror(text: String, image: UIImage?, alignment: Alignment = .right) {
        if image == nil {
            self.text = text
            return
        }
        
        let leftAttachment = NSTextAttachment()
        if alignment == .left {
            leftAttachment.image = image
            if let leftImage = leftAttachment.image {
                let imageSize = leftImage.size
                leftAttachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
            }
        } else {
            leftAttachment.image = image?.with(alpha: 0)
        }
        let leftAttributedString = NSAttributedString(attachment: leftAttachment)
        let leftIcon = NSMutableAttributedString(attributedString: leftAttributedString)
        
        let rightAttachment = NSTextAttachment()
        if alignment == .right {
            rightAttachment.image = image
            if let rightImage = rightAttachment.image {
                let imageSize = rightImage.size
                rightAttachment.bounds = CGRect(x: CGFloat(0), y: (font.capHeight - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
            }
        } else {
            rightAttachment.image = image?.with(alpha: 0)
        }
        let rightAttributedString = NSAttributedString(attachment: rightAttachment)
        let rightIcon = NSMutableAttributedString(attributedString: rightAttributedString)
        
        let labelText = NSMutableAttributedString(string: "  \(text)  ")
        labelText.append(rightIcon)
        leftIcon.append(labelText)
        self.attributedText = leftIcon
    }
    
}

extension UILabel {
    
    enum Alignment {
        case left
        case right
    }
    
}
