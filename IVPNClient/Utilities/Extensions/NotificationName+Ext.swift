//
//  NotificationName+Ext.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2018-11-06.
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

import Foundation

extension Notification.Name {
    
    public static let ServerSelected = Notification.Name("serverSelected")
    public static let Connect = Notification.Name("connect")
    public static let Disconnect = Notification.Name("disconnect")
    public static let TurnOffMultiHop = Notification.Name("turnOffMultiHop")
    public static let UpdateNetwork = Notification.Name("updateNetwork")
    public static let PingDidComplete = Notification.Name("pingDidComplete")
    public static let NetworkSaved = Notification.Name("networkSaved")
    public static let TermsOfServiceAgreed = Notification.Name("termsOfServiceAgreed")
    public static let SubscriptionDismissed = Notification.Name("subscriptionDismissed")
    public static let SubscriptionActivated = Notification.Name("subscriptionActivated")
    public static let ServiceAuthorized = Notification.Name("serviceAuthorized")
    public static let AuthenticationDismissed = Notification.Name("authenticationDismissed")
    public static let NewSession = Notification.Name("newSession")
    public static let ForceNewSession = Notification.Name("forceNewSession")
    public static let VPNConnectError = Notification.Name("vpnConnectError")
    public static let VPNConfigurationDisabled = Notification.Name("vpnConfigurationDisabled")
    public static let UpdateFloatingPanelLayout = Notification.Name("updateFloatingPanelLayout")
    public static let UpdateControlPanel = Notification.Name("updateControlPanel")
    public static let ProtocolSelected = Notification.Name("protocolSelected")
    public static let HideConnectionInfoPopup = Notification.Name("hideConnectionInfoPopup")
    public static let ShowConnectToServerPopup = Notification.Name("showConnectToServerPopup")
    public static let HideConnectToServerPopup = Notification.Name("hideConnectToServerPopup")
    public static let CenterMap = Notification.Name("centerMap")
    public static let UpdateGeoLocation = Notification.Name("updateGeoLocation")
    public static let UpdateResolvedDNS = Notification.Name("updateResolvedDNS")
    public static let UpdateResolvedDNSInsideVPN = Notification.Name("updateResolvedDNSInsideVPN")
    public static let ResolvedDNSError = Notification.Name("resolvedDNSError")
    public static let ServersListUpdated = Notification.Name("serversListUpdated")
    public static let AntiTrackerUpdated = Notification.Name("antiTrackerUpdated")
    public static let AntiTrackerListUpdated = Notification.Name("antiTrackerListUpdated")
    public static let CustomDNSUpdated = Notification.Name("customDNSUpdatedUpdated")
    public static let EvaluateReconnect = Notification.Name("evaluateReconnect")
    public static let EvaluatePlanUpdate = Notification.Name("evaluatePlanUpdate")
    
}
