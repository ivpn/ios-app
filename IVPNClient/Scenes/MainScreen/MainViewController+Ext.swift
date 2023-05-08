//
//  MainViewController+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-02-19.
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
import FloatingPanel

// MARK: - FloatingPanelControllerDelegate -

extension MainViewController: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        updateAccessibilityLabel(vc: vc)
        
        return FloatingPanelMainLayout()
    }
    
    func floatingPanelShouldBeginDragging(_ vc: FloatingPanelController) -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad && UIWindow.isLandscape && !UIApplication.shared.isSplitOrSlideOver ? false : true
    }
    
    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        updateAccessibilityLabel(vc: vc)
    }
    
    func updateAccessibilityLabel(vc: FloatingPanelController) {
        if let controlPanelViewController = floatingPanel.contentViewController, UIDevice.current.userInterfaceIdiom != .pad {
            if vc.position == .full {
                controlPanelViewController.view.accessibilityLabel = "Swipe down to collapse control panel"
            } else {
                controlPanelViewController.view.accessibilityLabel = "Swipe up to expan control panel"
            }
        }
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension MainViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        floatingPanel.updateLayout()
        NotificationCenter.default.post(name: Notification.Name.UpdateControlPanel, object: nil)
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let controlPanelViewController = floatingPanel.contentViewController {
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.ServiceAuthorized, object: nil)
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.SubscriptionActivated, object: nil)
        }
    }
    
}

// MARK: - VPNErrorObserverDelegate -

extension MainViewController: VPNErrorObserverDelegate {
    
    func presentError(title: String, message: String) {
        showErrorAlert(title: title, message: message)
    }
    
}
