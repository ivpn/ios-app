//
//  InfoAlertView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 12/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

protocol InfoAlertViewDelegate: class {
    func action()
}

class InfoAlertView: UIView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - @IBActions -
    
    @IBAction func action(_ sender: UIButton) {
        delegate?.action()
    }
    
    // MARK: - Properties -
    
    weak var delegate: InfoAlertViewDelegate?
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        isHidden = true
    }
    
    // MARK: - Methods -
    
    func show(type: InfoAlertViewType = .info, text: String = "", actionText: String = "") {
        setupAppearance(type: type)
        setupText(text: text)
        setupAction(actionText: actionText)
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    func updateAutoLayout() {
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            bottomConstraint.constant = 342
            return
        }

        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn {
            bottomConstraint.constant = 257
            return
        }
        
        bottomConstraint.constant = 213
    }
    
    // MARK: - Private methods -
    
    func setupAppearance(type: InfoAlertViewType) {
        switch type {
        case .alert:
            backgroundColor = UIColor.init(named: Theme.Key.ivpnLightYellow)
            textLabel.textColor = UIColor.init(named: Theme.Key.ivpnDarkYellow)
            actionButton.setTitleColor(UIColor.init(named: Theme.Key.ivpnDarkYellow), for: .normal)
            iconImage.image = UIImage(named: "icon-alert-dark-yellow")
            break
        case .info:
            backgroundColor = UIColor.init(named: Theme.Key.ivpnLightNavy)
            textLabel.textColor = UIColor.init(named: Theme.Key.ivpnDarkNavy)
            actionButton.setTitleColor(UIColor.init(named: Theme.Key.ivpnDarkNavy), for: .normal)
            iconImage.image = UIImage(named: "alert-info-dark-navy")
            break
        }
    }
    
    func setupText(text: String) {
        textLabel.text = text
    }
    
    func setupAction(actionText: String) {
        if actionText.isEmpty {
            actionButton.isHidden = true
        } else {
            actionButton.setTitle(actionText, for: .normal)
        }
    }
    
}

// MARK: - InfoAlertView extension -

extension InfoAlertView {
    
    enum InfoAlertViewType {
        case alert
        case info
    }
    
}
