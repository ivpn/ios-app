//
//  IpProtocolView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-04-14.
//  Copyright (c) 2021 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

class IpProtocolView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var controlView: UISegmentedControl!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint!
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        updateLayout()
    }
    
    // MARK: - Methods -
    
    func update(ipv4ViewModel: ProofsViewModel?, ipv6ViewModel: ProofsViewModel?) {
        guard let ipv4ViewModel = ipv4ViewModel, let ipv6ViewModel = ipv6ViewModel else {
            isHidden = true
            controlView.selectedSegmentIndex = 0
            return
        }
        
        guard let ipv4Model = ipv4ViewModel.model, let ipv6Model = ipv6ViewModel.model else {
            isHidden = true
            controlView.selectedSegmentIndex = 0
            return
        }
        
        guard Application.shared.connectionManager.status.isDisconnected() else {
            isHidden = true
            controlView.selectedSegmentIndex = 0
            return
        }
        
        if ipv6Model.isEqualLocation(to: ipv4Model) {
            isHidden = true
            controlView.selectedSegmentIndex = 0
        } else {
            isHidden = false
        }
    }
    
    func updateLayout() {
        if UIDevice.current.userInterfaceIdiom == .pad && !UIApplication.shared.isSplitOrSlideOver {
            topConstraint.constant = 40
            
            if UIWindow.isLandscape {
                centerXConstraint.constant = CGFloat(MapConstants.Container.iPadLandscapeLeftAnchor / 2)
                
            } else {
                centerXConstraint.constant = 0
            }
        }
    }
    
}
