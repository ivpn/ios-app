//
//  CustomDNSViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 28/02/2019.
//  Copyright © 2019 IVPN. All rights reserved.
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
