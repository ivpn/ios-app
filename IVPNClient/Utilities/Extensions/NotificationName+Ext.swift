//
//  NotificationName.swift
//  IVPN Client
//
//  Created by Juraj Hilje on 06/12/2018.
//  Copyright © 2018 IVPN. All rights reserved.
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
    public static let ShowLogin = Notification.Name("showLogin")
    public static let ShowCreateAccount = Notification.Name("showCreateAccount")
    public static let UpdateFloatingPanelLayout = Notification.Name("updateFloatingPanelLayout")
    public static let UpdateControlPanel = Notification.Name("updateControlPanel")
    public static let ProtocolSelected = Notification.Name("protocolSelected")
    public static let HideConnectionInfoPopup = Notification.Name("hideConnectionInfoPopup")
    public static let HideConnectToServerPopup = Notification.Name("hideConnectToServerPopup")
    public static let CenterMap = Notification.Name("centerMap")
    
}
