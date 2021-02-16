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
        if #available(iOS 14.0, *) {
            switch sender.isOn {
            case true:
                guard let ipAddress = model.ipAddress, !ipAddress.isEmpty else {
                    showAlert(title: "", message: "Please enter DNS server first") { _ in
                        sender.setOn(false, animated: true)
                    }
                    
                    return
                }
                
                DNSManager.shared.saveProfile(model: model) { error in
                    if let error = error {
                        self.showErrorAlert(title: "Error", message: "There was an error saving DNS profile: \(error.localizedDescription)") { _ in
                            sender.setOn(false, animated: true)
                        }
                        return
                    }
                    
                    self.showActionSheet(title: "Enable your DNS config in iOS Settings - General - VPN & Network - DNS", actions: ["Open iOS Settings"], sourceView: self.secureDNSView.enableSwitch) { index in
                        switch index {
                        case 0:
                            UIApplication.openNetworkSettings()
                        default:
                            sender.setOn(false, animated: true)
                        }
                    }
                }
            case false:
                DNSManager.shared.removeProfile() { _ in }
            }
        }
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        model.type = sender.selectedSegmentIndex == 1 ? "dot" : "doh"
    }
    
    @IBAction func changeMobileNetwork(_ sender: UISwitch) {
        model.mobileNetwork = sender.isOn
    }
    
    @IBAction func changeWifiNetwork(_ sender: UISwitch) {
        model.wifiNetwork = sender.isOn
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secureDNSView.setupView(model: model)
    }
    
    // MARK: - Methods -
    
    @objc func cancelTapped() {
        secureDNSView.setupView(model: model)
        view.endEditing(true)
    }
    
    @objc func saveTapped() {
        saveIpAddress()
        view.endEditing(true)
    }
    
    func saveIpAddress() {
        guard let text = secureDNSView.ipAddressField.text else {
            return
        }
        
        if text.isEmpty {
            model.ipAddress = nil
            return
        }
        
        do {
            let ipAddress = try CIDRAddress(stringRepresentation: text)
            model.ipAddress = ipAddress?.ipAddress
        } catch {
            showAlert(title: "Invalid DNS Server", message: "The IP Address (\(text)) is invalid.")
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension SecureDNSViewController {

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
        if textField == secureDNSView.ipAddressField {
            textField.resignFirstResponder()
            saveIpAddress()
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
