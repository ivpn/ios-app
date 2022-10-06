//
//  PortViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2022-07-11.
//  Copyright (c) 2022 Privatus Limited.
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

class PortViewController: UITableViewController {
    
    // MARK: - Properties -
    
    var viewModel = PortViewModel()
    var portRanges = Application.shared.serverList.getPortRanges(tunnelType: Application.shared.settings.connectionProtocol.formatTitle())
    var selectedPort = Application.shared.settings.connectionProtocol
    var selectedPortIndex = 0
    var updatedPortRange: PortRange?
    var updatedTextField: UITextField?
    
    var ports: [ConnectionSettings] {
        return Application.shared.settings.connectionProtocol.supportedProtocols(protocols: Application.shared.serverList.ports)
    }
    
    var customPorts: [ConnectionSettings] {
        return PortRange.getPorts(from: portRanges, tunnelType: selectedPort.formatTitle())
    }
    
    var collection: [ConnectionSettings] {
        return ports + customPorts
    }
    
    // MARK: - @IBActions -
    
    @IBAction func addCustomPort(_ sender: Any) {
        let vpnProtocol = Application.shared.settings.connectionProtocol.formatTitle()
        let viewController = NavigationManager.getAddCustomPortViewController(delegate: self, vpnProtocol: vpnProtocol)
        present(viewController, animated: true)
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        title = "Select Port"
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
    }
    
    @objc func cancel() {
        view.endEditing(true)
        tableView.reloadData()
    }
    
    @objc func save() {
        if let text = updatedTextField?.text {
            let port = Int(text) ?? 0
            if let error = updatedPortRange?.save(port: port) {
                showAlert(title: "Error", message: error)
            }
            
            if port == 0, let firstPort = collection.first {
                selectedPort = firstPort
            } else {
                selectedPort = collection[selectedPortIndex]
            }
        }
        
        Application.shared.settings.connectionProtocol = selectedPort
        view.endEditing(true)
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource -

extension PortViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return portRanges.count
        }
        
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 1 {
//            let range = portRanges[indexPath.row]
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PortInputTableViewCell", for: indexPath) as! PortInputTableViewCell
//            cell.setup(range: range)
//            cell.portInput.delegate = self
//            return cell
//        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPortTableViewCell", for: indexPath)
            return cell
        }
        
        let port = collection[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortTableViewCell", for: indexPath) as! PortTableViewCell
        cell.setup(port: port, selectedPort: selectedPort, ports: ports)
        
        if port == selectedPort {
            selectedPortIndex = indexPath.row
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Select port"
        default:
            return ""
        }
    }
    
}

// MARK: - UITableViewDelegate -

extension PortViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPort = collection[indexPath.row]
        Application.shared.settings.connectionProtocol = selectedPort
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name.ProtocolSelected, object: nil)
        navigationController?.popViewController(animated: true)
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

extension PortViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        save()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        var superview = (textField as AnyObject).superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view?.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        updatedPortRange = portRanges[indexPath.row]
        updatedTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        DispatchQueue.async {
            self.updatedPortRange = nil
            self.updatedTextField = nil
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - AddCustomPortViewControllerDelegate -

extension PortViewController: AddCustomPortViewControllerDelegate {
    
    func customPortAdded(port: ConnectionSettings) {
        print("port", port)
    }
    
}
