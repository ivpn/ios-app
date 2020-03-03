//
//  MainViewControllerV2+Ext.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import FloatingPanel

// MARK: - FloatingPanelControllerDelegate -

extension MainViewControllerV2: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return FloatingPanelMainLayout()
    }
    
    func floatingPanelShouldBeginDragging(_ vc: FloatingPanelController) -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad ? false : true
    }
    
}


// MARK: - UIAdaptivePresentationControllerDelegate -

extension MainViewControllerV2: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        if let viewController = floatingPanel.contentViewController as? ControlPanelViewController {
            viewController.reloadView()
        }
        
        floatingPanel.updateLayout()
    }
    
}
