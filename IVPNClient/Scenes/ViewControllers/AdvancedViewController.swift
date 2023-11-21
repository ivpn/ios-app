//
//  AdvancedViewController.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-08-19.
//  Copyright (c) 2023 IVPN Limited.
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
import ActiveLabel
import WidgetKit

class AdvancedViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var disableLanAccessSwitch: UISwitch!
    @IBOutlet weak var askToReconnectSwitch: UISwitch!
    @IBOutlet weak var preventSameCountryMultiHopSwitch: UISwitch!
    @IBOutlet weak var preventSameISPMultiHopSwitch: UISwitch!
    @IBOutlet weak var loggingSwitch: UISwitch!
    @IBOutlet weak var loggingCell: UITableViewCell!
    @IBOutlet weak var sendLogsLabel: UILabel!
    @IBOutlet weak var v2raySwitch: UISwitch!
    @IBOutlet weak var v2rayProtocolControl: UISegmentedControl!
    
    // MARK: - Properties -
    
    var protocolType: String {
        return v2rayProtocolControl.selectedSegmentIndex == 1 ? "tcp" : "udp"
    }
    
    // MARK: - @IBActions -
    
    @IBAction func toggleDisableLanAccess(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() == .ipsec {
            showAlert(title: "IKEv2 not supported", message: "Block LAN traffic is supported only for OpenVPN and WireGuard protocols.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.disableLanAccess)
        evaluateReconnect(sender: sender as UIView)
    }
    
    @IBAction func toggleV2ray(_ sender: UISwitch) {
        if sender.isOn && Application.shared.settings.connectionProtocol.tunnelType() != .wireguard {
            showAlert(title: "OpenVPN and IKEv2 not supported", message: "V2Ray is supported only for WireGuard protocol.") { _ in
                sender.setOn(false, animated: true)
            }
            return
        }
        
        if !sender.isOn {
            Application.shared.settings.connectionProtocol = Config.defaultProtocol
        }
        
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isV2ray)
        evaluateReconnect(sender: sender as UIView)
        WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
    }
    
    @IBAction func selectV2rayProtocol(_ sender: UISegmentedControl) {
        let v2rayProtocol = sender.selectedSegmentIndex == 1 ? "tcp" : "udp"
        UserDefaults.shared.set(v2rayProtocol, forKey: UserDefaults.Key.v2rayProtocol)
        
        if UserDefaults.shared.isV2ray {
            Application.shared.settings.connectionProtocol = Config.defaultProtocol
            evaluateReconnect(sender: sender as UIView)
            WidgetCenter.shared.reloadTimelines(ofKind: "IVPNWidget")
        }
    }
    
    @IBAction func toggleAskToReconnect(_ sender: UISwitch) {
        UserDefaults.shared.set(!sender.isOn, forKey: UserDefaults.Key.notAskToReconnect)
    }
    
    @IBAction func togglePreventSameCountryMultiHop(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaults.Key.preventSameCountryMultiHop)
    }
    
    @IBAction func togglePreventSameISPMultiHop(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaults.Key.preventSameISPMultiHop)
    }
    
    @IBAction func toggleLogging(_ sender: UISwitch) {
        UserDefaults.shared.set(sender.isOn, forKey: UserDefaults.Key.isLogging)
        FileSystemManager.clearSession()
        setupLoggingView()
    }
    
    // MARK: - View Lifecycle -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    // MARK: - Methods -
    
    private func setupView() {
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        disableLanAccessSwitch.setOn(UserDefaults.shared.disableLanAccess, animated: false)
        askToReconnectSwitch.setOn(!UserDefaults.shared.notAskToReconnect, animated: false)
        preventSameCountryMultiHopSwitch.setOn(UserDefaults.standard.preventSameCountryMultiHop, animated: false)
        preventSameISPMultiHopSwitch.setOn(UserDefaults.standard.preventSameISPMultiHop, animated: false)
        loggingSwitch.setOn(UserDefaults.shared.isLogging, animated: false)
        v2raySwitch.setOn(UserDefaults.shared.isV2ray, animated: false)
        v2rayProtocolControl.selectedSegmentIndex = UserDefaults.shared.v2rayProtocol == "tcp" ? 1 : 0
        setupLoggingView()
    }
    
    private func setupLoggingView() {
        loggingCell.isUserInteractionEnabled = UserDefaults.shared.isLogging ? true : false
        sendLogsLabel.alpha = UserDefaults.shared.isLogging ? 1 : 0.65
        sendLogsLabel.textColor = UserDefaults.shared.isLogging ? UIColor.init(named: Theme.ivpnBlue) : UIColor.init(named: Theme.ivpnLabel5)
    }
    
    private func sendLogs() {
        guard evaluateIsLoggedIn() else {
            return
        }

        guard let appLogPath = FileManager.logTextFileURL?.path else {
            return
        }
        
        guard let wireguardLogPath = FileManager.wgLogTextFileURL?.path else {
            return
        }
        
        guard logger.app?.writeLog(to: appLogPath) ?? false else {
            return
        }
        
        guard logger.wireguard?.writeLog(to: wireguardLogPath) ?? false else {
            return
        }
        
        var logFiles = [URL]()
        var openvpnLogAttached = false
        var presentMailComposer = true
        
        // App logs
        var appLog = ""
        if let file = NSData(contentsOfFile: appLogPath) {
            appLog = String(data: file as Data, encoding: .utf8) ?? ""
        }
        
        FileSystemManager.updateLogFile(newestLog: appLog, name: Config.appLogFile, isLoggedIn: Application.shared.authentication.isLoggedIn)
        
        let logFile = FileSystemManager.sharedFilePath(name: Config.appLogFile).path
        if let fileData = NSData(contentsOfFile: logFile) {
            appLog = String(data: fileData as Data, encoding: .utf8) ?? ""
            logFiles.append(FileSystemManager.tempFile(text: appLog, fileName: "app-\(Date.logFileName())"))
        }
        
        // WireGuard tunnel logs
        var wireguardLog = ""
        if let file = NSData(contentsOfFile: wireguardLogPath) {
            wireguardLog = String(data: file as Data, encoding: .utf8) ?? ""
        }
        
        FileSystemManager.updateLogFile(newestLog: wireguardLog, name: Config.wireGuardLogFile, isLoggedIn: Application.shared.authentication.isLoggedIn)
        
        let wireguardLogFile = FileSystemManager.sharedFilePath(name: Config.wireGuardLogFile).path
        if let fileData = NSData(contentsOfFile: wireguardLogFile) {
            wireguardLog = String(data: fileData as Data, encoding: .utf8) ?? ""
            logFiles.append(FileSystemManager.tempFile(text: wireguardLog, fileName: "wireguard-\(Date.logFileName())"))
        }
        
        // OpenVPN tunnel logs
        Application.shared.connectionManager.getOpenVPNLog { openVPNLog in
            if UserDefaults.shared.isLogging {
                FileSystemManager.updateLogFile(newestLog: openVPNLog, name: Config.openVPNLogFile, isLoggedIn: Application.shared.authentication.isLoggedIn)
                
                let logFile = FileSystemManager.sharedFilePath(name: Config.openVPNLogFile).path
                var openvpnLog = ""
                if let file = NSData(contentsOfFile: logFile), !openvpnLogAttached {
                    openvpnLog = String(data: file as Data, encoding: .utf8) ?? ""
                    logFiles.append(FileSystemManager.tempFile(text: openvpnLog, fileName: "openvpn-\(Date.logFileName())"))
                    openvpnLogAttached = true
                }
            }
            
            if presentMailComposer {
                let activityView = UIActivityViewController(activityItems: logFiles, applicationActivities: nil)
                activityView.popoverPresentationController?.sourceView = self.view
                self.present(activityView, animated: true, completion: nil)
                if let popOver = activityView.popoverPresentationController {
                    popOver.sourceView = self.sendLogsLabel
                }
                presentMailComposer = false
            }
        }
    }

}

// MARK: - UITableViewDelegate -

extension AdvancedViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 && indexPath.row == 0 {
            return 60
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            sendLogs()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        
        var urlString = ""
        switch section {
        case 1:
            urlString = "https://www.ivpn.net/knowledgebase/ios/v2ray/"
        default:
            urlString = "https://www.ivpn.net/knowledgebase/ios/known-issues-with-native-ios-kill-switch/"
        }
        
        let label = ActiveLabel(frame: .zero)
        let customType = ActiveType.custom(pattern: "Learn more")
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.enabledTypes = [customType]
        label.text = footer.textLabel?.text
        label.textColor = UIColor.init(named: Theme.ivpnLabel6)
        label.customColor[customType] = UIColor.init(named: Theme.ivpnBlue)
        label.handleCustomTap(for: customType) { _ in
            self.openWebPage(urlString)
        }
        footer.addSubview(label)
        footer.textLabel?.text = ""
        label.bindFrameToSuperviewBounds(leading: 16, trailing: -16)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}
