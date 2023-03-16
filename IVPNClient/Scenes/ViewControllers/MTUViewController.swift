//
//  MTUViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-03-15.
//  Copyright (c) 2023 Privatus Limited.
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

protocol MTUViewControllerDelegate: AnyObject {
    func mtuSaved()
}

class MTUViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var mtuTextField: UITextField!
    
    // MARK: - Properties -
    
    weak var delegate: MTUViewControllerDelegate?
    
    private var getMtu: Int {
        return Int(mtuTextField.text ?? "") ?? 0
    }
    
    private let mtuLowerBound = 576
    private let mtuUpperBound = 65535
    
    // MARK: - @IBActions -
    
    @IBAction func saveMtu() {
        guard isValid(mtu: getMtu) else {
            showErrorAlert(title: "Error", message: "Expected value: [\(mtuLowerBound) - \(mtuUpperBound)]")
            return
        }
        
        UserDefaults.standard.setValue(getMtu, forKey: UserDefaults.Key.wgMtu)
        navigationController?.dismiss(animated: true) { [self] in
            delegate?.mtuSaved()
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        let mtu = UserDefaults.standard.wgMtu
        mtuTextField.text = mtu > 0 ? String(mtu) : nil
        mtuTextField.placeholder = "\(mtuLowerBound) - \(mtuUpperBound)"
    }
    
    private func isValid(mtu: Int) -> Bool {
        return (mtu >= mtuLowerBound && mtu <= mtuUpperBound) || mtu == 0
    }

}

// MARK: - UITextFieldDelegate -

extension MTUViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mtuTextField {
            textField.resignFirstResponder()
            saveMtu()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
}

