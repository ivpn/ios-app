import XCTest

@testable import IVPNClient

class UserDefaultsTests: XCTestCase {
    
    func test_properties() {
        XCTAssertNotNil(UserDefaults.shared.wireguardTunnelProviderError)
        XCTAssertNotNil(UserDefaults.shared.isMultiHop)
        XCTAssertNotNil(UserDefaults.shared.exitServerLocation)
        XCTAssertNotNil(UserDefaults.shared.isLogging)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionEnabled)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionUntrustedConnect)
        XCTAssertNotNil(UserDefaults.shared.networkProtectionTrustedDisconnect)
        XCTAssertNotNil(UserDefaults.shared.isCustomDNS)
        XCTAssertNotNil(UserDefaults.shared.customDNS)
        XCTAssertNotNil(UserDefaults.shared.isAntiTracker)
        XCTAssertNotNil(UserDefaults.shared.isAntiTrackerHardcore)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerDNS)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerDNSMultiHop)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerHardcoreDNS)
        XCTAssertNotNil(UserDefaults.shared.antiTrackerHardcoreDNSMultiHop)
        XCTAssertNotNil(UserDefaults.shared.wgKeyTimestamp)
        XCTAssertNotNil(UserDefaults.shared.wgRegenerationRate)
        XCTAssertNotNil(UserDefaults.shared.localIpAddress)
        XCTAssertNotNil(UserDefaults.shared.serversSort)
    }
    
}
