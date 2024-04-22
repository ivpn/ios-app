//
//  Alerts+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2017-01-04.
//  Copyright (c) 2023 IVPN Limited.
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

import Foundation
import UIKit
import JGProgressHUD

extension UIViewController {
    
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        self.showErrorAlert(title: title, message: message, handler: handler)
    }
    
    func showErrorAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showActionAlert(title: String, message: String, action: String, cancel: String = "Cancel", cancelHandler: ((UIAlertAction) -> Void)? = nil, actionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: actionHandler))
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: cancelHandler))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(image: UIImage? = nil, selected: String? = nil, largeText: Bool = false, centered: Bool = false, title message: String = "", actions: [String] = [], cancelAction: String = "Cancel", sourceView: UIView = UIView(), disableDismiss: Bool = false, permittedArrowDirections: UIPopoverArrowDirection = [.any], completion: @escaping (_ index: Int) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        let messageFont: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: largeText ? 17 : 16)]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        for (index, value) in actions.enumerated() {
            let alertAction = UIAlertAction(title: value, style: .default) { _ in
                completion(index)
            }
            
            if let selected = selected {
                if value == selected {
                    let image = UIImage.init(named: "icon-check-2")
                    alertAction.setValue(image, forKey: "image")
                }
            }
            
            alert.addAction(alertAction)
        }
        
        let cancelAction = UIAlertAction(title: cancelAction, style: .cancel) { _ in
            alert.dismiss(animated: true, completion: {
                completion(-1)
            })
        }
        
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
            popoverController.permittedArrowDirections = permittedArrowDirections
            if centered {
                popoverController.permittedArrowDirections = []
            }
        }

        present(alert, animated: true) {
            if disableDismiss && UIDevice.current.userInterfaceIdiom == .phone {
                alert.view.superview?.subviews[0].isUserInteractionEnabled = false
            }
        }
    }
    
    func showFlashNotification(message: String, presentInView: UIView = UIView(), dismissAfter: TimeInterval = 2) {
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = nil
        hud.interactionType = .blockNoTouches
        hud.detailTextLabel.text = message
        hud.show(in: presentInView)
        hud.dismiss(afterDelay: dismissAfter)
    }
    
}
