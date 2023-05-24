//
//  SecureDNSViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2021-02-15.
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
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

class SecureDNSViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var secureDNSView: SecureDNSView!
    
    // MARK: - Properties -
    
    private var model = SecureDNS()
    
    // MARK: - @IBActions -
    
    @IBAction func enable(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "DNS over HTTPS/TLS is supported only when using OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        switch sender.isOn {
        case true:
            saveDNSProfile()
        case false:
            removeDNSProfile()
        }
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        model.type = sender.selectedSegmentIndex == 1 ? "dot" : "doh"
        updateDNSProfile()
        tableView.reloadData()
    }
    
    @IBAction func changeMobileNetwork(_ sender: UISwitch) {
        model.mobileNetwork = sender.isOn
        updateDNSProfile()
    }
    
    @IBAction func changeWifiNetwork(_ sender: UISwitch) {
        model.wifiNetwork = sender.isOn
        updateDNSProfile()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        secureDNSView.setupView(model: model)
        addObservers()
        hideKeyboardOnTap()
    }
    
    // MARK: - Methods -
    
    @objc func cancelTapped() {
        secureDNSView.setupView(model: model)
        view.endEditing(true)
    }
    
    @objc func saveTapped() {
        saveAddress()
        view.endEditing(true)
    }
    
    // MARK: - Private methods -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDNSProfile), name: Notification.Name.UpdateResolvedDNS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resolvedDNSError), name: Notification.Name.ResolvedDNSError, object: nil)
    }
    
    private func saveDNSProfile() {
        let validation = model.validation()
        
        guard validation.0 else {
            showAlert(title: "", message: validation.1 ?? "Invalid DNS configuration") { _ in
                self.secureDNSView.enableSwitch.setOn(false, animated: true)
            }
            
            return
        }
        
        DNSManager.shared.saveProfile(model: model) { error in
            if let error = error, error.code != 9 {
                self.showErrorAlert(title: "Error", message: "There was an error saving DNS profile: \(error.localizedDescription)") { _ in
                    self.secureDNSView.enableSwitch.setOn(false, animated: true)
                }
                return
            }
            
            if !DNSManager.shared.isEnabled {
                self.showActionSheet(title: "Select IVPN in iOS Settings - VPN & Network - DNS", actions: ["Open iOS Settings"], sourceView: self.secureDNSView.enableSwitch) { index in
                    switch index {
                    case 0:
                        UIApplication.openNetworkSettings()
                    default:
                        self.secureDNSView.enableSwitch.setOn(false, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func updateDNSProfile() {
        DNSManager.shared.saveProfile(model: model) { _ in }
    }
    
    private func removeDNSProfile() {
        DNSManager.shared.removeProfile { _ in
            DNSManager.shared.loadProfile { _ in
                
            }
        }
    }
    
    private func saveAddress() {
        guard var server = secureDNSView.serverField.text else {
            return
        }
        
        server = DNSProtocolType.sanitizeServer(address: server)
        model.address = server
        
        if server.isEmpty {
            UserDefaults.standard.set([], forKey: UserDefaults.Key.resolvedDNSOutsideVPN)
            removeDNSProfile()
            secureDNSView.enableSwitch.setOn(false, animated: true)
        }
        
        secureDNSView.setupView(model: model)
    }
    
    @objc private func resolvedDNSError() {
        secureDNSView.serverField.text = ""
        model.address = ""
        removeDNSProfile()
        secureDNSView.enableSwitch.setOn(false, animated: true)
        secureDNSView.setupView(model: model)
        showResolvedDNSError()
    }
    
}

// MARK: - UITableViewDelegate -

extension SecureDNSViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = DNSProtocolType.init(rawValue: model.type)
        
        if type == .dot && indexPath.section == 1 && indexPath.row == 2 {
            return 0
        }
        
        if type == .doh && indexPath.section == 1 && indexPath.row == 3 {
            return 0
        }
        
        return 45
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

extension SecureDNSViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == secureDNSView.serverField {
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
            self.secureDNSView.setupView(model: self.model)
        }
    }
    
}
