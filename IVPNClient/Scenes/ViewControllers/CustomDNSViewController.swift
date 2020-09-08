//
//  CustomDNSViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-02-28.
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

class CustomDNSViewController: UITableViewController {
    
    @IBOutlet weak var customDNSSwitch: UISwitch!
    @IBOutlet weak var customDNSTextField: UITextField!
    
    @IBAction func toggleCustomDNS(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "Custom DNS is supported only for OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isCustomDNS)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        hideKeyboardOnTap()
        customDNSSwitch.isOn = UserDefaults.shared.isCustomDNS
        customDNSTextField.text = UserDefaults.shared.customDNS
        customDNSTextField.delegate = self
    }
    
    // MARK: - Methods -
    
    @objc func cancelTapped() {
        customDNSTextField.text = UserDefaults.shared.customDNS
        view.endEditing(true)
    }
    
    @objc func saveTapped() {
        saveCustomDNS()
        view.endEditing(true)
    }
    
    func saveCustomDNS() {
        guard let text = customDNSTextField.text else { return }
        
        if text.isEmpty {
            UserDefaults.shared.set("", forKey: UserDefaults.Key.customDNS)
            return
        }
        
        do {
            let address = try CIDRAddress(stringRepresentation: text)
            UserDefaults.shared.set(address?.ipAddress, forKey: UserDefaults.Key.customDNS)
        } catch {
            showAlert(title: "Invalid Custom DNS Server", message: "The IP Address (\(text)) is invalid.")
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension CustomDNSViewController {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}

// MARK: - UITextFieldDelegate -

extension CustomDNSViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == customDNSTextField {
            textField.resignFirstResponder()
            saveCustomDNS()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        DispatchQueue.async {
            self.customDNSTextField.text = UserDefaults.shared.customDNS
        }
    }
    
}
