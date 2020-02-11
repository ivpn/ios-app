//
//  UIImage+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 25/01/2019.
//  Copyright © 2019 IVPN. All rights reserved.
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
    
}
