//
//  MainViewControllerV2.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import FloatingPanel

class MainViewControllerV2: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var infoAlertBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties -
    
    var floatingPanel: FloatingPanelController!
    private var updateServerListDidComplete = false
    private var updateServersTimer = Timer()
    
    // MARK: - @IBActions -
    
    @IBAction func openSettings(_ sender: UIButton) {
        presentSettingsScreen()
        
        if let controlPanelViewController = floatingPanel.contentViewController {
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.TermsOfServiceAgreed, object: nil)
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.NewSession, object: nil)
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.ForceNewSession, object: nil)
        }
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFloatingPanel()
        addObservers()
        startServersUpdate()
        updateInfoAlert()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPingService(updateServerListDidComplete: updateServerListDidComplete)
    }
    
    deinit {
        destoryFloatingPanel()
        removeObservers()
        updateServersTimer.invalidate()
    }
    
    // MARK: - Segues -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ControlPanelSelectServer" {
            if let navController = segue.destination as? UINavigationController {
                if let viewController = navController.topViewController as? ServerViewController {
                    viewController.serverDelegate = floatingPanel.contentViewController as! ControlPanelViewController
                }
            }
        }
        
        if segue.identifier == "ControlPanelSelectExitServer" {
            if let navController = segue.destination as? UINavigationController {
                if let viewController = navController.topViewController as? ServerViewController {
                    viewController.isExitServer = true
                }
            }
        }
        
        if segue.identifier == "MainScreenNetworkProtectionRules" {
            if let navController = segue.destination as? UINavigationController {
                if let viewController = navController.topViewController as? NetworkTrustViewController {
                    let controlPanelViewController = floatingPanel.contentViewController as! ControlPanelViewController
                    viewController.network = Application.shared.network
                    viewController.delegate = controlPanelViewController.networkView
                }
            }
        }
    }
    
    // MARK: - Methods -
    
    func updateGeoLocation() {
        let request = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup)
        
        ApiService.shared.request(request) { [weak self] (result: Result<GeoLookup>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                if let controlPanelViewController = self.floatingPanel.contentViewController as? ControlPanelViewController {
                    controlPanelViewController.connectionInfoViewModel = ProofsViewModel(model: model)
                }
            case .failure:
                break
            }
        }
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFloatingPanelLayout), name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    // MARK: - Private methods -
    
    @objc private func updateFloatingPanelLayout() {
        floatingPanel.updateLayout()
        updateInfoAlert()
    }
    
    @objc private func updateServersList() {
        ApiService.shared.getServersList(storeInCache: true) { result in
            self.updateServerListDidComplete = true
            switch result {
            case .success(let serverList):
                Application.shared.serverList = serverList
                Pinger.shared.serverList = Application.shared.serverList
                Pinger.shared.ping()
            default:
                break
            }
        }
    }
    
    private func updateInfoAlert() {
        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn && UserDefaults.shared.isMultiHop {
            infoAlertBottomConstraint.constant = 342
            return
        }

        if Application.shared.settings.connectionProtocol.tunnelType() == .openvpn {
            infoAlertBottomConstraint.constant = 257
            return
        }
        
        infoAlertBottomConstraint.constant = 213
    }
    
    private func initFloatingPanel() {
        floatingPanel = FloatingPanelController()
        floatingPanel.setup()
        floatingPanel.delegate = self
        floatingPanel.addPanel(toParent: self)
        floatingPanel.show(animated: true)
    }
    
    private func destoryFloatingPanel() {
        floatingPanel.removePanelFromParent(animated: false)
    }
    
    private func startServersUpdate() {
        updateServersList()
        updateServersTimer = Timer.scheduledTimer(timeInterval: 60 * 15, target: self, selector: #selector(updateServersList), userInfo: nil, repeats: true)
    }
    
    private func startPingService(updateServerListDidComplete: Bool) {
        if updateServerListDidComplete {
            DispatchQueue.delay(0.5) {
                Pinger.shared.ping()
            }
        }
    }
    
}
