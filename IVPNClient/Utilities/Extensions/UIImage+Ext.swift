//
//  UIImage+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-01-25.
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
import CoreGraphics

extension UIImage {
    
    func with(alpha: CGFloat = 1.0) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        return UIGraphicsImageRenderer(size: self.size, format: format).image { context in
            draw(in: context.format.bounds, blendMode: .normal, alpha: alpha)
        }
    }
    
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func processCaptcha(userInterfaceStyle: UIUserInterfaceStyle) -> UIImage? {
        let ciImage = CIImage(image: self)
        var filter = CIFilter(name: "CIPhotoEffectMono")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let outputImage = filter?.outputImage {
            if userInterfaceStyle == .light {
                return UIImage(ciImage: outputImage)
            }
            
            filter = CIFilter(name: "CIColorInvert")
            filter?.setValue(outputImage, forKey: kCIInputImageKey)
            
            if let outputImage = filter?.outputImage {
                return UIImage(ciImage: outputImage)
            }
        }
        
        return nil
    }
    
}
