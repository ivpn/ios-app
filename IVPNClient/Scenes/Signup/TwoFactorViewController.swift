//
//  TwoFactorViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-12-10.
//  Copyright (c) 2020 Privatus Limited.
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

protocol TwoFactorViewControllerDelegate: class {
    func codeSubmitted(code: String)
}

class TwoFactorViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var codeField: UITextField! {
        didSet {
            codeField.delegate = self
        }
    }
    
    // MARK: - Properties -
    
    weak var delegate: TwoFactorViewControllerDelegate?
    
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
    
    // MARK: - Methods -
    
    private func submit() {
        let code = codeField.text ?? ""
        
        guard ServiceStatus.isValid(verificationCode: code) else {
            showValidationError()
            return
        }
        
        delegate?.codeSubmitted(code: code)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func showValidationError() {
        showErrorAlert(
            title: "Invalid code",
            message: "Please enter 6-digit verification code"
        )
    }

}

// MARK: - UITextFieldDelegate -

extension TwoFactorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        codeField.resignFirstResponder()
        submit()
        
        return true
    }
    
}
