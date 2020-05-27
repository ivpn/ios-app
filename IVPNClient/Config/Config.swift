import UIKit

struct Config {
    
    static let useDebugServers = false
    static let useDebugWireGuardKeyUpgrade = false
    static let minPingCheckInterval: TimeInterval = 10
    static let appGroup = "group.net.ivpn.clients.ios"
    
    static let apiServersFile = "/v4/servers.json"
    static let apiValidateAccount = "/subscriptions/validate"
    static let apiSubscription = "/subscriptions/ios"
    static let apiGeoLookup = "/v4/geo-lookup"
    static let apiSessionNew = "/v4/session/new"
    static let apiSessionStatus = "/v4/session/status"
    static let apiSessionDelete = "/v4/session/delete"
    static let apiSessionWGKeySet = "/v4/session/wg/set"
    
    static let urlTypeLogin = "login"
    static let urlTypeConnect = "connect"
    static let urlTypeDisconnect = "disconnect"
    
    static let ikev2TunnelTitle = "IVPN IKEv2"
    static let openvpnTunnelProvider = "net.ivpn.clients.ios.openvpn-tunnel-provider"
    static let openvpnTunnelTitle = "IVPN OpenVPN"
    static let wireguardTunnelProvider = "net.ivpn.clients.ios.wireguard-tunnel-provider"
    static let wireguardTunnelTitle = "IVPN WireGuard"
    
    // Files and Directories
    static let serversListCacheFileName = "servers_cache1.json"
    static let openVPNLogFile = "OpenVPNLogs.txt"
    
    // Contact Support web page
    static let contactSupportMail = "support@ivpn.net"
    static let contactSupportPage = "mailto:support@ivpn.net"
    
    static let daysBeforeDueDateNotification = 5
    static let serviceStatusRefreshMaxIntervalSeconds: TimeInterval = 60
    
    static let defaultProtocol = ConnectionSettings.ipsec
    static let supportedProtocols = [
        ConnectionSettings.ipsec,
        ConnectionSettings.openvpn(.udp, 2049),
        ConnectionSettings.openvpn(.udp, 2050),
        ConnectionSettings.openvpn(.udp, 53),
        ConnectionSettings.openvpn(.udp, 1194),
        ConnectionSettings.openvpn(.tcp, 443),
        ConnectionSettings.openvpn(.tcp, 1443),
        ConnectionSettings.openvpn(.tcp, 80),
        ConnectionSettings.wireguard(.udp, 2049),
        ConnectionSettings.wireguard(.udp, 2050),
        ConnectionSettings.wireguard(.udp, 53),
        ConnectionSettings.wireguard(.udp, 1194),
        ConnectionSettings.wireguard(.udp, 30587),
        ConnectionSettings.wireguard(.udp, 41893),
        ConnectionSettings.wireguard(.udp, 48574),
        ConnectionSettings.wireguard(.udp, 58237)
    ]
    
    // MARK: WireGuard
    
    static let wgPeerAllowedIPs = "0.0.0.0/0"
    static let wgPeerPersistentKeepalive: Int32 = 25
    static let wgInterfaceListenPort = 51820
    static let wgAPIComment = "IVPN Client for iOS"
    static let wgKeyExpirationDays = 30
    static let wgKeyRegenerationRate = 1
    
    // MARK: ENV variables
    
    static var Environment: String {
        return value(for: "Environment")
    }
    
    static var SentryDsn: String {
        return value(for: "SentryDsn")
    }
    
    static var ApiHostName: String {
        return value(for: "ApiHostName")
    }
    
    static var TlsHostName: String {
        return value(for: "TlsHostName")
    }
    
    static var IAPSharedSecret: String {
        return value(for: "IAPSharedSecret")
    }
    
    // MARK: ENV .xcconfig parser
    
    static func value<T>(for key: String) -> T {
        guard let value = Bundle.main.infoDictionary?[key] as? T else {
            fatalError("Invalid or missing Info.plist key: \(key)")
        }
        
        return value
    }
    
}
