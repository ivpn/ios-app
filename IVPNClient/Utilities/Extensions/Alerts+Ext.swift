//
//  Alerts.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 1/4/17.
//  Copyright © 2017 IVPN. All rights reserved.
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
    
    func showActionSheet(image: UIImage? = nil, selected: String? = nil, largeText: Bool = false, centered: Bool = false, title message: String = "", actions: [String] = [], sourceView: UIView = UIView(), completion: @escaping (_ index: Int) -> Void) {
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: {
                completion(-1)
            })
        }
        
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
            if centered {
                popoverController.permittedArrowDirections = []
            }
        }

        present(alert, animated: true, completion: nil)
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
