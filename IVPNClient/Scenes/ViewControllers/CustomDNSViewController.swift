//
//  CustomDNSViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-02-28.
//  Copyright (c) 2023 IVPN Limited.
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
    @IBOutlet weak var customDNSIPTextField: UITextField!
    @IBOutlet weak var customDNSTextField: UITextField!
    @IBOutlet weak var secureDNSSwitch: UISwitch!
    @IBOutlet weak var serverURLLabel: UILabel!
    @IBOutlet weak var serverNameLabel: UILabel!
    @IBOutlet weak var typeControl: UISegmentedControl!
    
    // MARK: - @IBActions -
    
    @IBAction func toggleCustomDNS(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "Custom DNS is supported only for OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        guard let server = customDNSIPTextField.text, !server.isEmpty else {
            showAlert(title: "", message: "Please enter DNS server info") { _ in
                sender.setOn(false, animated: true)
            }
            
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isCustomDNS)
        evaluateReconnect(sender: sender)
    }
    
    @IBAction func enableSecureDNS(_ sender: UISwitch) {
        typeControl.isEnabled = sender.isOn
        let preferred: DNSProtocolType = typeControl.selectedSegmentIndex == 1 ? .dot : .doh
        DNSProtocolType.save(preferred: sender.isOn ? preferred : .plain)
        tableView.reloadData()
        
        if UserDefaults.shared.isCustomDNS {
            evaluateReconnect(sender: customDNSTextField)
        }
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        let preferred: DNSProtocolType = sender.selectedSegmentIndex == 1 ? .dot : .doh
        DNSProtocolType.save(preferred: preferred)
        tableView.reloadData()
        
        if UserDefaults.shared.isCustomDNS {
            evaluateReconnect(sender: customDNSTextField)
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTap()
        setupView()
        addObservers()
    }
    
    // MARK: - Methods -
    
    @objc func cancelTapped() {
        customDNSIPTextField.text = UserDefaults.shared.resolvedDNSInsideVPN.joined(separator: ",")
        customDNSTextField.text = UserDefaults.shared.customDNS
        view.endEditing(true)
    }
    
    @objc func saveTapped() {
        saveAddress()
        saveURL()
        view.endEditing(true)
    }
    
    func saveAddress() {
        guard let address = customDNSIPTextField.text else {
            return
        }
        
        UserDefaults.shared.set(address.commaSeparatedToArray(), forKey: UserDefaults.Key.resolvedDNSInsideVPN)
        
        if address.isEmpty {
            UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
            UserDefaults.shared.set("", forKey: UserDefaults.Key.customDNS)
            customDNSSwitch.setOn(false, animated: true)
        }
        
        setupView()
        
        if UserDefaults.shared.isCustomDNS {
            evaluateReconnect(sender: customDNSTextField)
        }
    }
    
    func saveURL() {
        guard var server = customDNSTextField.text else {
            return
        }
        
        server = DNSProtocolType.sanitizeServer(address: server)
        customDNSTextField.text = server
        
        UserDefaults.shared.set(server, forKey: UserDefaults.Key.customDNS)
        
        setupView()
        
        if UserDefaults.shared.isCustomDNS {
            evaluateReconnect(sender: customDNSTextField)
        }
    }
    
    // MARK: - Private methods -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupView), name: Notification.Name.CustomDNSUpdated, object: nil)
    }
    
    @objc private func setupView() {
        let preferred = DNSProtocolType.preferredSettings()
        let customDNS = UserDefaults.shared.customDNS
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        customDNSSwitch.isOn = UserDefaults.shared.isCustomDNS
        customDNSIPTextField.text = UserDefaults.shared.resolvedDNSInsideVPN.joined(separator: ",")
        customDNSTextField.text = customDNS
        customDNSTextField.delegate = self
        serverURLLabel.text = DNSProtocolType.getServerURL(address: customDNS)
        serverNameLabel.text = DNSProtocolType.getServerName(address: customDNS)
        secureDNSSwitch.isOn = preferred != .plain
        typeControl.isEnabled = preferred != .plain
        typeControl.selectedSegmentIndex = preferred == .dot ? 1 : 0
    }
    
}

// MARK: - UITableViewDelegate -

extension CustomDNSViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let type = DNSProtocolType.preferredSettings()
        if type == .plain {
            return 3
        }
        
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            let type = DNSProtocolType.preferredSettings()
            
            if type != .doh && indexPath.row == 1 {
                return 0
            }
            
            if type != .dot && indexPath.row == 2 {
                return 0
            }
            
            if type == .plain {
                return 0
            }
        }
        
        return UITableView.automaticDimension
    }
    
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
        if textField == customDNSIPTextField {
            textField.resignFirstResponder()
            saveAddress()
        }
        
        if textField == customDNSTextField {
            textField.resignFirstResponder()
            saveURL()
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
            self.customDNSIPTextField.text = UserDefaults.shared.resolvedDNSInsideVPN.joined(separator: ",")
            self.customDNSTextField.text = UserDefaults.shared.customDNS
        }
    }
    
}
