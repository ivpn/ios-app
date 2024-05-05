//
//  AddCustomPortViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-10-06.
//  Copyright (c) 2022 IVPN Limited.
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

protocol AddCustomPortViewControllerDelegate: AnyObject {
    func customPortAdded(port: ConnectionSettings) -> Bool
    func portSelected()
}

class AddCustomPortViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var typeControl: UISegmentedControl!
    
    // MARK: - Properties -
    
    weak var delegate: AddCustomPortViewControllerDelegate?
    var protocolType: String {
        return typeControl.selectedSegmentIndex == 1 ? "TCP" : "UDP"
    }
    var port: Int {
        return Int(portTextField.text ?? "") ?? 0
    }
    let portRanges = Application.shared.serverList.getPortRanges(tunnelType: Application.shared.settings.connectionProtocol.formatTitle())
    var selectedPortRange: PortRange?
    
    // MARK: - @IBActions -
    
    @IBAction func addPort() {
        if let err = selectedPortRange?.validate(port: port) {
            showErrorAlert(title: "Invalid input", message: err)
            return
        }
        
        let vpnProtocol = Application.shared.settings.connectionProtocol.formatTitle().lowercased()
        let customPort = ConnectionSettings.getFrom(portString: "\(vpnProtocol)-\(protocolType.lowercased())-\(port)")
        let success = delegate?.customPortAdded(port: customPort) ?? false
        
        if success {
            navigationController?.dismiss(animated: true) { [self] in
                delegate?.portSelected()
            }
        } else {
            showErrorAlert(title: "Invalid input", message: "Port '\(protocolType) \(port)' already exists")
        }
    }
    
    @IBAction func selectType(_ sender: UISegmentedControl) {
        updateSelectedPortRange()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedPortRange()
        typeControl.isEnabled = Application.shared.settings.connectionProtocol.tunnelType() == .openvpn
        typeControl.selectedSegmentIndex = UserDefaults.shared.isV2ray && UserDefaults.shared.v2rayProtocol == "tcp" && Application.shared.settings.connectionProtocol.tunnelType() == .wireguard ? 1 : 0
    }
    
    // MARK: - Methods -
    
    private func updateSelectedPortRange() {
        selectedPortRange = portRanges.first(where: { $0.protocolType == protocolType })
        portTextField.placeholder = selectedPortRange?.portRangesText
    }

}

// MARK: - UITextFieldDelegate -

extension AddCustomPortViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == portTextField {
            textField.resignFirstResponder()
            addPort()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
}
