//
//  ControlPanelView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2020-04-07.
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
    @IBOutlet weak var exitServerCountryLabel: UILabel!
    @IBOutlet weak var exitServerFlagImage: UIImageView!
    @IBOutlet weak var exitServerIPv6Label: UILabel!
    @IBOutlet weak var entryServerTableCell: UITableViewCell!
    @IBOutlet weak var entryServerConnectionLabel: UILabel!
    @IBOutlet weak var entryServerNameLabel: UILabel!
    @IBOutlet weak var entryServerCountryLabel: UILabel!
    @IBOutlet weak var entryServerFlagImage: UIImageView!
    @IBOutlet weak var entryServerIPv6Label: UILabel!
    @IBOutlet weak var antiTrackerSwitch: UISwitch!
    @IBOutlet weak var antiTrackerLabel: UILabel!
    @IBOutlet weak var networkView: NetworkViewTableCell!
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var connectionInfoView: ConnectionInfoView!
    
    // MARK: - Properties -
    
    var ipv4ViewModel: ProofsViewModel! {
        didSet {
            connectionInfoView.update(ipv4ViewModel: ipv4ViewModel, ipv6ViewModel: ipv6ViewModel, addressType: addressType)
        }
    }
    
    var ipv6ViewModel: ProofsViewModel! {
        didSet {
            connectionInfoView.update(ipv4ViewModel: ipv4ViewModel, ipv6ViewModel: ipv6ViewModel, addressType: addressType)
        }
    }
    
    var addressType: AddressType = .IPv4 {
        didSet {
            connectionInfoView.update(ipv4ViewModel: ipv4ViewModel, ipv6ViewModel: ipv6ViewModel, addressType: addressType)
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
        updateConnectSwitch()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: protectionStatusTableCell)
        
        if UIDevice.screenHeightSmallerThan(device: .iPhones66s78) {
            protectionStatusLabel.font = protectionStatusLabel.font.withSize(28)
        }
    }
    
    func updateVPNStatus(viewModel: VPNStatusViewModel, animated: Bool = true) {
        protectionStatusLabel.text = viewModel.protectionStatusText
        connectSwitch.setOn(viewModel.connectToggleIsOn, animated: animated)
        connectSwitch.accessibilityLabel = viewModel.connectToggleIsOn ? "Switch to disconnect" : "Switch to connect"
        updateConnectSwitch()
        updateServerNames()
    }
    
    func updateServerLabels(viewModel: VPNStatusViewModel) {
        entryServerConnectionLabel.text = viewModel.connectToServerText
        exitServerConnectionLabel.text = viewModel.connectToExitServerText
    }
    
    func updateServerNames() {
        updateServerName(server: Application.shared.settings.selectedServer, label: entryServerNameLabel, flag: entryServerFlagImage, ipv6Label: entryServerIPv6Label, selectedHost: Application.shared.settings.selectedHost)
        updateServerName(server: Application.shared.settings.selectedExitServer, label: exitServerNameLabel, flag: exitServerFlagImage, ipv6Label: exitServerIPv6Label, selectedHost: Application.shared.settings.selectedExitHost)
        
        entryServerCountryLabel.text = Application.shared.settings.selectedServer.country
        exitServerCountryLabel.text = Application.shared.settings.selectedExitServer.country
    }
    
    func updateAntiTracker(viewModel: VPNStatusViewModel) {
        antiTrackerSwitch.isOn = UserDefaults.shared.isAntiTracker
        antiTrackerSwitch.onTintColor = UserDefaults.shared.isAntiTrackerHardcore ? UIColor.init(named: Theme.ivpnDarkRed) : UIColor.init(named: Theme.ivpnBlue)
        antiTrackerLabel.text = viewModel.antiTrackerText
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
    
    private func updateServerName(server: VPNServer, label: UILabel, flag: UIImageView, ipv6Label: UILabel, selectedHost: Host? = nil) {
        let serverViewModel = VPNServerViewModel(server: server, selectedHost: selectedHost)
        label.text = serverViewModel.formattedServerNameForMainScreen
        flag.image = serverViewModel.imageForCountryCodeForMainScreen
        ipv6Label.isHidden = !serverViewModel.showIPv6Label
    }
    
    private func updateConnectSwitch() {
        connectSwitch.subviews[0].subviews[0].backgroundColor = UIColor.init(named: Theme.ivpnRedOff)
    }
    
}
