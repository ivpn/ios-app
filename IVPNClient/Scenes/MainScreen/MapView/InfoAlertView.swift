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
    
    // MARK: - Properties -
    
    weak var delegate: InfoAlertViewDelegate?
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        isHidden = true
    }
    
    // MARK: - Methods -
    
    func show(type: InfoAlertViewType = .info, text: String = "", actionText: String = "") {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    // MARK: - Private methods -
    
    private func setupAppearance(type: InfoAlertViewType) {
        // TODO: setup UIView background color
    }
    
    private func setupText(text: String) {
        // TODO: setup UILabel text
    }
    
    private func setupAction(actionText: String) {
        // TODO: setup UIButton action
    }
    
}

extension InfoAlertView {
    
    enum InfoAlertViewType {
        case alert
        case info
    }
    
}
