//
//  ConnectionInfoPopupView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 18/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import Bamboo

extension UIView {

    /**
     Rotate a view by specified degrees

     - parameter angle: angle in degrees
     */
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }

}

class ConnectionInfoPopupView: UIView {
    
    // MARK: - View components -
    
    lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        container.layer.cornerRadius = 8
        container.clipsToBounds = false
        return container
    }()
    
    lazy var arrow: UIView = {
        let arrow = UIView(frame: .zero)
        arrow.backgroundColor = UIColor.init(named: Theme.Key.ivpnBackgroundPrimary)
        arrow.rotate(angle: 45)
        return arrow
    }()
    
    lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.text = "Everyone knows about your location"
        statusLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabel5)
        return statusLabel
    }()
    
    lazy var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.iconMirror(text: "Kyiv, UA", image: UIImage(named: "ua"), alignment: .left)
        locationLabel.textColor = UIColor.init(named: Theme.Key.ivpnLabelPrimary)
        return locationLabel
    }()
    
    var actionButton: UIButton = {
        let actionButton = UIButton()
        actionButton.setImage(UIImage.init(named: "icon-info-2"), for: .normal)
        actionButton.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
        return actionButton
    }()
    
    // MARK: - View lifecycle -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func updateConstraints() {
        setupConstraints()
        super.updateConstraints()
    }
    
    // MARK: - Private methods -
    
    private func setupConstraints() {
        bb.size(width: 270, height: 69).centerX().bottom(15)
    }
    
    private func setupView() {
        layer.masksToBounds = false
        clipsToBounds = false
        
        addSubsviews()
    }
    
    private func addSubsviews() {
        container.addSubview(statusLabel)
        container.addSubview(locationLabel)
        container.addSubview(actionButton)
        addSubview(arrow)
        addSubview(container)
        
        setupSubsviewsConstraints()
    }
    
    private func setupSubsviewsConstraints() {
        container.bb.fill()
        arrow.bb.size(width: 14, height: 14).centerX().top(-7)
        statusLabel.bb.left(18).top(15).right(-18).height(14)
        locationLabel.bb.left(18).bottom(-15).right(-48).height(19)
        actionButton.bb.size(width: 20, height: 20).bottom(-15).right(-18)
    }
    
    @objc private func infoAction() {
        
    }
    
}
