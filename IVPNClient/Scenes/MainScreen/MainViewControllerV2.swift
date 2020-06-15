//
//  MainViewControllerV2.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 19/02/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit
import FloatingPanel
import NetworkExtension

class MainViewControllerV2: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var mainView: MainView!
    
    // MARK: - Properties -
    
    var floatingPanel: FloatingPanelController!
    private var updateServerListDidComplete = false
    private var updateServersTimer = Timer()
    private var vpnErrorObserver = VPNErrorObserver()
    
    // MARK: - @IBActions -
    
    @IBAction func openSettings(_ sender: UIButton) {
        presentSettingsScreen()
        
        if let controlPanelViewController = floatingPanel.contentViewController {
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.TermsOfServiceAgreed, object: nil)
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.NewSession, object: nil)
            NotificationCenter.default.removeObserver(controlPanelViewController, name: Notification.Name.ForceNewSession, object: nil)
        }
    }
    
    @IBAction func openAccountInfo(_ sender: UIButton) {
        guard evaluateIsLoggedIn() else {
            return
        }
        
        presentAccountScreen()
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initErrorObservers()
        initFloatingPanel()
        addObservers()
        startServersUpdate()
        startVPNStatusObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPingService(updateServerListDidComplete: updateServerListDidComplete)
        refreshUI()
        updateGeoLocation()
    }
    
    deinit {
        removeObservers()
        updateServersTimer.invalidate()
        Application.shared.connectionManager.removeStatusChangeUpdates()
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
    }
    
    // MARK: - Interface Orientations -
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        refreshUI()
    }
    
    // MARK: - Methods -
    
    func refreshUI() {
        updateFloatingPanelLayout()
    }
    
    func updateStatus(vpnStatus: NEVPNStatus, animated: Bool = true) {
        mainView.updateStatus(vpnStatus: vpnStatus)
        
        if let controlPanelViewController = self.floatingPanel.contentViewController as? ControlPanelViewController {
            controlPanelViewController.updateStatus(vpnStatus: vpnStatus, animated: animated)
        }
    }
    
    func updateGeoLocation() {
        guard let controlPanelViewController = self.floatingPanel.contentViewController as? ControlPanelViewController else {
            return
        }
        
        let request = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup)
        
        mainView.infoAlertViewModel.infoAlert = .subscriptionExpiration
        mainView.updateInfoAlert()
        controlPanelViewController.controlPanelView.connectionInfoDisplayMode = .loading
        
        ApiService.shared.request(request) { [weak self] (result: Result<GeoLookup>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                let viewModel = ProofsViewModel(model: model)
                controlPanelViewController.connectionViewModel = viewModel
                self.mainView.connectionViewModel = viewModel
            case .failure:
                controlPanelViewController.controlPanelView.connectionInfoDisplayMode = .error
                self.mainView.infoAlertViewModel.infoAlert = .connectionInfoFailure
                self.mainView.updateInfoAlert()
            }
        }
    }
    
    func expandFloatingPanel() {
        floatingPanel.move(to: .full, animated: true)
    }
    
    // MARK: - Observers -
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFloatingPanelLayout), name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(vpnConfigurationDisabled), name: Notification.Name.VPNConfigurationDisabled, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.VPNConfigurationDisabled, object: nil)
    }
    
    // MARK: - Private methods -
    
    @objc private func updateFloatingPanelLayout() {
        floatingPanel.updateLayout()
        mainView.setupView(animated: false)
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
    
    @objc private func vpnConfigurationDisabled() {
        updateStatus(vpnStatus: Application.shared.connectionManager.status)
    }
    
    private func initFloatingPanel() {
        floatingPanel = FloatingPanelController()
        floatingPanel.setup()
        floatingPanel.delegate = self
        floatingPanel.addPanel(toParent: self)
        floatingPanel.show(animated: true)
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
    
    private func startVPNStatusObserver() {
        Application.shared.connectionManager.getStatus { _, status in
            self.updateStatus(vpnStatus: status, animated: false)
            
            Application.shared.connectionManager.onStatusChanged { status in
                self.updateStatus(vpnStatus: status)
            }
        }
    }
    
    private func initErrorObservers() {
        vpnErrorObserver.delegate = self
    }
    
}
