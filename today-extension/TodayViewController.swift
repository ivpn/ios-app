//
//  TodayViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2019-09-16.
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
import NotificationCenter
import NetworkExtension

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var disconnectedView: UIView!
    @IBOutlet weak var connectedView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    
    // MARK: - Properties -
    
    var viewModel: ViewModel! {
        didSet {
            let connectionLocation = viewModel.connectionLocation
            let connectionIpAddress = viewModel.connectionIpAddress
            locationLabel.text = connectionLocation
            ipAddressLabel.text = connectionIpAddress
            UserDefaults.shared.set(connectionLocation, forKey: UserDefaults.Key.connectionLocation)
            UserDefaults.shared.set(connectionIpAddress, forKey: UserDefaults.Key.connectionIpAddress)
        }
    }
    
    var displayMode: DisplayMode! {
        didSet {
            switch displayMode {
            case .login?:
                loginView.isHidden = false
                disconnectedView.isHidden = true
                connectedView.isHidden = true
                actionButton.backgroundColor = UIColor.init(named: "ivpnBlue")
                logoView.backgroundColor = UIColor.init(named: "ivpnGray")
                UIView.performWithoutAnimation {
                    self.actionButton.setTitle("Log In", for: .normal)
                    self.actionButton.layoutIfNeeded()
                }
            case .disconnected?:
                loginView.isHidden = true
                disconnectedView.isHidden = false
                connectedView.isHidden = true
                actionButton.backgroundColor = UIColor.init(named: "ivpnBlue")
                logoView.backgroundColor = UIColor.init(named: "ivpnGray")
                UIView.performWithoutAnimation {
                    self.actionButton.setTitle("Connect", for: .normal)
                    self.actionButton.layoutIfNeeded()
                }
            case .connected?:
                loginView.isHidden = true
                disconnectedView.isHidden = true
                connectedView.isHidden = false
                actionButton.backgroundColor = UIColor.init(named: "ivpnGray")
                logoView.backgroundColor = UIColor.init(named: "ivpnBlue")
                UIView.performWithoutAnimation {
                    self.actionButton.setTitle("Disconnect", for: .normal)
                    self.actionButton.layoutIfNeeded()
                }
            case .none:
                break
            }
            
            actionButton.isHidden = false
            logoView.isHidden = false
        }
    }
    
    var latestStatus: NEVPNStatus = .invalid
    
    // MARK: - @IBActions -
    
    @IBAction func action(_ sender: Any) {
        sendActionToMainApp(displayMode: displayMode)
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startVPNStatusMonitor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        guard UserDefaults.shared.isLoggedIn else {
            if displayMode != .login {
                displayMode = .login
                completionHandler(.newData)
                return
            }
            
            completionHandler(.noData)
            return
        }
        
        guard ViewModel.currentStatus == .connected else {
            if displayMode != .disconnected {
                displayMode = .disconnected
                completionHandler(.newData)
                return
            }
            
            completionHandler(.noData)
            return
        }
        
        if displayMode != .connected {
            displayMode = .connected
            completionHandler(.newData)
        }
        
        geoLookup { completion in
            completionHandler(completion)
        }
    }
    
    // MARK: - Methods -
    
    private func updateView() {
        guard UserDefaults.shared.isLoggedIn else {
            displayMode = .login
            return
        }
        
        guard ViewModel.currentStatus == .connected else {
            displayMode = .disconnected
            return
        }
        
        displayMode = .connected
        locationLabel.text = UserDefaults.shared.connectionLocation
        ipAddressLabel.text = UserDefaults.shared.connectionIpAddress
        geoLookup { _ in }
    }
    
    private func geoLookup(completion: (@escaping (NCUpdateResult) -> Void)) {
        let request = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup)
        
        ApiManager.shared.request(request) { (result: Result<GeoLookup>) in
            switch result {
            case .success(let model):
                self.viewModel = ViewModel(model: model)
                completion(.newData)
            case .failure:
                completion(.failed)
            }
        }
    }
    
    private func sendActionToMainApp(displayMode: DisplayMode) {
        var endpoint = Config.urlTypeLogin
        
        if displayMode == .disconnected {
            endpoint = Config.urlTypeConnect
        }
        
        if displayMode == .connected {
            endpoint = Config.urlTypeDisconnect
        }
        
        let url = URL(string: "ivpn://\(endpoint)")!
        extensionContext?.open(url) { _ in }
    }
    
    private func startVPNStatusMonitor() {
        let timer = TimerManager(timeInterval: 2)
        timer.eventHandler = {
            if self.latestStatus != ViewModel.currentStatus {
                DispatchQueue.async {
                    self.updateView()
                }
                self.latestStatus = ViewModel.currentStatus
            }
            
            if (self.displayMode == .login && UserDefaults.shared.isLoggedIn) || (self.displayMode != .login && !UserDefaults.shared.isLoggedIn) {
                DispatchQueue.async {
                    self.updateView()
                }
            }
            
            timer.proceed()
        }
        timer.resume()
    }
    
}

extension TodayViewController {
    
    enum DisplayMode {
        case login
        case disconnected
        case connected
    }
    
}
