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
    @IBOutlet weak var secureDNSSwitch: UISwitch!
    @IBOutlet weak var resolvedIPLabel: UILabel!
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
        
        guard let server = customDNSTextField.text, !server.isEmpty else {
            showAlert(title: "", message: "Please enter DNS server info") { _ in
                sender.setOn(false, animated: true)
            }
            
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isCustomDNS)
        evaluateReconnect(sender: sender)
        
        if sender.isOn {
            registerUserActivity(type: UserActivityType.CustomDNSEnable, title: UserActivityTitle.CustomDNSEnable)
        } else {
            registerUserActivity(type: UserActivityType.CustomDNSDisable, title: UserActivityTitle.CustomDNSDisable)
        }
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
        customDNSTextField.text = UserDefaults.shared.customDNS
        view.endEditing(true)
    }
    
    @objc func saveTapped() {
        saveAddress()
        view.endEditing(true)
    }
    
    func saveAddress() {
        guard var server = customDNSTextField.text else {
            return
        }
        
        server = DNSProtocolType.sanitizeServer(address: server)
        customDNSTextField.text = server
        
        let serverToResolve = DNSProtocolType.getServerToResolve(address: server)
        DNSManager.saveResolvedDNS(server: serverToResolve, key: UserDefaults.Key.resolvedDNSInsideVPN)
        
        UserDefaults.shared.set(server, forKey: UserDefaults.Key.customDNS)
        
        if server.isEmpty {
            UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
            UserDefaults.shared.set([], forKey: UserDefaults.Key.resolvedDNSInsideVPN)
            customDNSSwitch.setOn(false, animated: true)
        }
        
        setupView()
        
        if UserDefaults.shared.isCustomDNS {
            evaluateReconnect(sender: customDNSTextField)
        }
    }
    
    @objc func updateResolvedDNS() {
        let resolvedDNS = UserDefaults.shared.value(forKey: UserDefaults.Key.resolvedDNSInsideVPN) as? [String]
            ?? []
        resolvedIPLabel.text = resolvedDNS.map { String($0) }.joined(separator: ",")
    }
    
    // MARK: - Private methods -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateResolvedDNS), name: Notification.Name.UpdateResolvedDNSInsideVPN, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resolvedDNSError), name: Notification.Name.ResolvedDNSError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupView), name: Notification.Name.CustomDNSUpdated, object: nil)
    }
    
    @objc private func setupView() {
        let preferred = DNSProtocolType.preferredSettings()
        let customDNS = UserDefaults.shared.customDNS
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        customDNSSwitch.isOn = UserDefaults.shared.isCustomDNS
        customDNSTextField.text = customDNS
        customDNSTextField.delegate = self
        serverURLLabel.text = DNSProtocolType.getServerURL(address: customDNS)
        serverNameLabel.text = DNSProtocolType.getServerName(address: customDNS)
        secureDNSSwitch.isOn = preferred != .plain
        typeControl.isEnabled = preferred != .plain
        typeControl.selectedSegmentIndex = preferred == .dot ? 1 : 0
        updateResolvedDNS()
    }
    
    @objc private func resolvedDNSError() {
        customDNSTextField.text = ""
        UserDefaults.shared.set("", forKey: UserDefaults.Key.customDNS)
        UserDefaults.shared.set(false, forKey: UserDefaults.Key.isCustomDNS)
        customDNSSwitch.setOn(false, animated: true)
        setupView()
        showResolvedDNSError()
    }
    
}

// MARK: - UITableViewDelegate -

extension CustomDNSViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row > 0 {
            let type = DNSProtocolType.preferredSettings()
            
            if type != .doh && indexPath.row == 3 {
                return 0
            }
            
            if type != .dot && indexPath.row == 4 {
                return 0
            }
            
            if type == .plain && indexPath.row == 5 {
                return 0
            }
            
            return UITableView.automaticDimension
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
        if textField == customDNSTextField {
            textField.resignFirstResponder()
            saveAddress()
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
