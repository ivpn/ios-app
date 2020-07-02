//
//  FloatingPanelMainLayout.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import Foundation
import FloatingPanel

class FloatingPanelMainLayout: FloatingPanelLayout {
    
    // MARK: - Override public properties -
    
    public var initialPosition: FloatingPanelPosition {
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
            return .full
        }
        
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
            return [.full]
        }
        
        return [.full, .half]
    }
    
    // MARK: - Private properties -
    
    private let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    
    private var halfHeight: CGFloat {
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            return 359 - bottomSafeArea
        }
        
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn {
            return 274 - bottomSafeArea
        }
        
        return 230 - bottomSafeArea
    }
    
    // MARK: - Override public methods -

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
            switch position {
            case .full:
                return -20
            default:
                return nil
            }
        }
        
        switch position {
        case .full:
            return 10
        case .half:
            return halfHeight
        default:
            return nil
        }
    }

    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if let surfaceView = surfaceView as? FloatingPanelSurfaceView {
            if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
                surfaceView.grabberHandle.isHidden = true
                surfaceView.cornerRadius = 0
            } else {
                surfaceView.grabberHandle.isHidden = false
                surfaceView.cornerRadius = 15
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isLandscape {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
                surfaceView.widthAnchor.constraint(equalToConstant: 375)
            ]
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad && UIApplication.shared.statusBarOrientation.isPortrait {
            return [
                surfaceView.widthAnchor.constraint(equalToConstant: 520),
                surfaceView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ]
        }
        
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0),
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0),
        ]
    }
    
    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        if position == .full && (UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.statusBarOrientation.isPortrait) {
            return 0.3
        }
        
        return 0
    }
    
}
