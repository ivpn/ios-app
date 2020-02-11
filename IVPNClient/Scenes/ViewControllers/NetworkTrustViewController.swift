//
//  NetworkTrustViewController.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 21/11/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import UIKit

protocol NetworkTrustViewControllerDelegate: class {
    func selected(trust: String, indexPath: IndexPath)
}

class NetworkTrustViewController: UITableViewController {
    
    var collection = NetworkTrust.allCasesNormal
    var network = Network()
    var indexPath = IndexPath()
    weak var delegate: NetworkTrustViewControllerDelegate?
    
}

// MARK: - UITableViewDataSource -

extension NetworkTrustViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = collection[indexPath.row].rawValue
        cell.textLabel?.textColor = UIColor.init(named: Theme.Key.ivpnLabelPrimary)
        cell.tintColor = UIColor.init(named: Theme.Key.ivpnBlue)
        
        if collection[indexPath.row].rawValue == network.trust {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

}

// MARK: - UITableViewDelegate -

extension NetworkTrustViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard network.trust != collection[indexPath.row].rawValue else {
            tableView.reloadData()
            navigationController?.popViewController(animated: true)
            return
        }
        
        network.trust = collection[indexPath.row].rawValue
        tableView.reloadData()
        delegate?.selected(trust: network.trust ?? "", indexPath: self.indexPath)
        Application.shared.connectionManager.evaluateConnection()
        navigationController?.popViewController(animated: true)
    }

}
