//
//  ControlPanelView.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 07/04/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import UIKit

class ControlPanelView: UITableView {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var protectionStatusTableCell: UITableViewCell!
    @IBOutlet weak var protectionStatusLabel: UILabel!
    @IBOutlet weak var connectSwitch: UISwitch!
    @IBOutlet weak var enableMultiHopButton: UIButton!
    @IBOutlet weak var disableMultiHopButton: UIButton!
    @IBOutlet weak var exitServerTableCell: UITableViewCell!
    @IBOutlet weak var exitServerConnectionLabel: UILabel!
    @IBOutlet weak var exitServerNameLabel: UILabel!
    @IBOutlet weak var exitServerFlagImage: UIImageView!
    @IBOutlet weak var entryServerTableCell: UITableViewCell!
    @IBOutlet weak var entryServerConnectionLabel: UILabel!
    @IBOutlet weak var entryServerNameLabel: UILabel!
    @IBOutlet weak var entryServerFlagImage: UIImageView!
    @IBOutlet weak var fastestServerLabel: UIView!
    @IBOutlet weak var antiTrackerSwitch: UISwitch!
    @IBOutlet weak var networkView: NetworkViewTableCell!
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var ipAddressLoader: UIActivityIndicatorView!
    @IBOutlet weak var ipAddressErrorLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLoader: UIActivityIndicatorView!
    @IBOutlet weak var locationErrorLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var providerLoader: UIActivityIndicatorView!
    @IBOutlet weak var providerErrorLabel: UILabel!
    
    // MARK: - Properties -
    
    var connectionInfoDisplayMode: ConnectionInfoDisplayMode = .content {
        didSet {
            switch connectionInfoDisplayMode {
            case .loading:
                ipAddressLabel.isHidden = true
                ipAddressLoader.startAnimating()
                ipAddressErrorLabel.isHidden = true
                locationLabel.isHidden = true
                locationLoader.startAnimating()
                locationErrorLabel.isHidden = true
                providerLabel.isHidden = true
                providerLoader.startAnimating()
                providerErrorLabel.isHidden = true
            case .content:
                ipAddressLabel.isHidden = false
                ipAddressLoader.stopAnimating()
                ipAddressErrorLabel.isHidden = true
                locationLabel.isHidden = false
                locationLoader.stopAnimating()
                locationErrorLabel.isHidden = true
                providerLabel.isHidden = false
                providerLoader.stopAnimating()
                providerErrorLabel.isHidden = true
            case .error:
                ipAddressLabel.isHidden = true
                ipAddressLoader.stopAnimating()
                ipAddressErrorLabel.isHidden = false
                locationLabel.isHidden = true
                locationLoader.stopAnimating()
                locationErrorLabel.isHidden = false
                providerLabel.isHidden = true
                providerLoader.stopAnimating()
                providerErrorLabel.isHidden = false
            }
        }
    }
    
    // MARK: - View lifecycle -
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateConnectSwitch()
    }
    
    // MARK: - Methods -
    
    func setupView() {
        connectSwitch.thumbTintColor = UIColor.init(named: Theme.ivpnGray17)
        connectSwitch.onTintColor = UIColor.init(named: Theme.ivpnBlue)
        ipAddressErrorLabel.icon(text: "Connection error", imageName: "icon-wifi-off", alignment: .left)
        locationErrorLabel.icon(text: "Connection error", imageName: "icon-wifi-off", alignment: .left)
        providerErrorLabel.icon(text: "Connection error", imageName: "icon-wifi-off", alignment: .left)
        updateConnectSwitch()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: protectionStatusTableCell)
    }
    
    func updateConnectionInfo(viewModel: ProofsViewModel) {
        connectionInfoDisplayMode = .content
        ipAddressLabel.text = viewModel.ipAddress
        locationLabel.text = "\(viewModel.city), \(viewModel.countryCode)"
        providerLabel.text = viewModel.provider
    }
    
    func updateVPNStatus(viewModel: VPNStatusViewModel, animated: Bool = true) {
        protectionStatusLabel.text = viewModel.protectionStatusText
        connectSwitch.setOn(viewModel.connectToggleIsOn, animated: animated)
        connectSwitch.accessibilityLabel = viewModel.connectToggleIsOn ? "Switch to disconnect" : "Switch to connect"
        updateConnectSwitch()
    }
    
    func updateServerLabels(viewModel: VPNStatusViewModel) {
        entryServerConnectionLabel.text = viewModel.connectToServerText
        exitServerConnectionLabel.text = "Exit Server"
    }
    
    func updateServerNames() {
        updateServerName(server: Application.shared.settings.selectedServer, label: entryServerNameLabel, flag: entryServerFlagImage)
        updateServerName(server: Application.shared.settings.selectedExitServer, label: exitServerNameLabel, flag: exitServerFlagImage)
        
        fastestServerLabel.isHidden = !Application.shared.settings.selectedServer.fastest || Application.shared.settings.selectedServer.fastestServerLabelShouldBePresented
    }
    
    func updateAntiTracker() {
        antiTrackerSwitch.isOn = UserDefaults.shared.isAntiTracker
    }
    
    func updateProtocol() {
        let selectedProtocol = Application.shared.connectionManager.settings.connectionProtocol
        protocolLabel.text = selectedProtocol.format()
    }
    
    func updateMultiHopButtons(isMultiHop: Bool) {
        if isMultiHop {
            enableMultiHopButton.setTitleColor(UIColor.init(named: Theme.ivpnLabelPrimary), for: .normal)
            disableMultiHopButton.setTitleColor(UIColor.init(named: Theme.ivpnLabel5), for: .normal)
        } else {
            enableMultiHopButton.setTitleColor(UIColor.init(named: Theme.ivpnLabel5), for: .normal)
            disableMultiHopButton.setTitleColor(UIColor.init(named: Theme.ivpnLabelPrimary), for: .normal)
        }
    }
    
    // MARK: - Private methods -
    
    private func updateServerName(server: VPNServer, label: UILabel, flag: UIImageView) {
        let serverViewModel = VPNServerViewModel(server: server)
        label.icon(text: serverViewModel.formattedServerNameForMainScreen, imageName: serverViewModel.imageNameForPingTime)
        flag.image = serverViewModel.imageForCountryCodeForMainScreen
    }
    
    private func updateConnectSwitch() {
        if #available(iOS 13.0, *) {
            connectSwitch.subviews[0].subviews[0].backgroundColor = UIColor.init(named: Theme.ivpnRedOff)
        }
    }
    
}

extension ControlPanelView {
    
    enum ConnectionInfoDisplayMode {
        case loading
        case content
        case error
    }
    
}
