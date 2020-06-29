//
//  MainViewController+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import FloatingPanel

// MARK: - FloatingPanelControllerDelegate -

extension MainViewController: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return FloatingPanelMainLayout()
    }
    
    func floatingPanelShouldBeginDragging(_ vc: FloatingPanelController) -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape ? false : true
    }
    
    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        if vc.position == .full {
            updateGeoLocation()
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
        
        mainView.infoAlertViewModel.infoAlert = .subscriptionExpiration
        mainView.updateInfoAlert()
    }
    
}

// MARK: - VPNErrorObserverDelegate -

extension MainViewController: VPNErrorObserverDelegate {
    
    func presentError(title: String, message: String) {
        showErrorAlert(title: title, message: message)
    }
    
}
