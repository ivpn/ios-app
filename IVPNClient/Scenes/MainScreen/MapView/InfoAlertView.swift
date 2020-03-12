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
    
    // MARK: - Private methods -
    
    func setupAppearance(type: InfoAlertViewType) {
        // TODO: setup UIView background color
        // TODO: setup iconImage
        switch type {
        case .alert:
            break
        case .info:
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
