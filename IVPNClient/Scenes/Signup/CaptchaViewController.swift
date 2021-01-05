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
import JGProgressHUD

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
    
    private lazy var sessionManager: SessionManager = {
        let manager = SessionManager()
        manager.delegate = self
        return manager
    }()
    
    private let hud = JGProgressHUD(style: .dark)
    
    // MARK: - @IBActions -
    
    @IBAction func submitAction(_ sender: AnyObject) {
        submit()
    }
    
    @IBAction func reloadImageAction(_ sender: AnyObject) {
        reloadImage()
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
        
        guard UIApplication.shared.applicationState == .active else {
            return
        }
        
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
    
    private func reloadImage() {
        sessionManager.createSession(username: "i-XXXX-XXXX-XXXX")
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
        
        if traitCollection.userInterfaceStyle == .dark {
            captchaImage.image = UIImage.process(image: image, with: "CIColorInvert")
        } else {
            captchaImage.image = UIImage.process(image: image, with: "CIPhotoEffectMono")
        }
    }
    
}

// MARK: - SessionManagerDelegate -

extension CaptchaViewController {
    
    override func createSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Reloading captcha image..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func createSessionFailure(error: Any?) {
        var message = "There was an error creating a new session"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        showErrorAlert(title: "Error", message: message)
    }
    
    override func captchaRequired(error: Any?) {
        hud.dismiss()
        updateImageData(error: error)
    }
    
    override func captchaIncorrect(error: Any?) {
        hud.dismiss()
        updateImageData(error: error)
    }
    
    private func updateImageData(error: Any?) {
        if let error = error as? ErrorResultSessionNew {
            if let captchaImage = error.captchaImage {
                imageData = captchaImage
                processImage()
            }
        }
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
