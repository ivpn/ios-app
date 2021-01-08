//
//  CaptchaViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-01-04.
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
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

protocol CaptchaViewControllerDelegate: class {
    func captchaSubmitted(code: String, captchaId: String)
}

class CaptchaViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var codeField: UITextField! {
        didSet {
            codeField.delegate = self
        }
    }
    
    @IBOutlet weak var captchaImage: UIImageView!
    
    // MARK: - Properties -
    
    weak var delegate: CaptchaViewControllerDelegate?
    var imageData = ""
    var captchaId = ""
    
    // MARK: - @IBActions -
    
    @IBAction func submitAction(_ sender: AnyObject) {
        submit()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        hideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        processImage()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        processImage()
    }
    
    // MARK: - Methods -
    
    private func submit() {
        let code = codeField.text ?? ""
        
        guard ServiceStatus.isValid(verificationCode: code) else {
            showValidationError()
            return
        }
        
        delegate?.captchaSubmitted(code: code, captchaId: captchaId)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func showValidationError() {
        showErrorAlert(
            title: "Invalid code",
            message: "Please enter 6-digit verification code"
        )
    }
    
    private func processImage() {
        guard let image = imageData.base64ToImage() else {
            return
        }
        
        captchaImage.image = image.processCaptcha(userInterfaceStyle: traitCollection.userInterfaceStyle)
    }
    
}

// MARK: - UITextFieldDelegate -

extension CaptchaViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        codeField.resignFirstResponder()
        submit()
        
        return true
    }
    
}
