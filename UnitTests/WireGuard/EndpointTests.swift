import XCTest

@testable import IVPNClient

class EndpointTests: XCTestCase {
    
    func test_init() {
        let endpoint1 = ((try? Endpoint(endpointString: "10.0.0.0:53")) as Endpoint??)
        XCTAssertEqual(endpoint1??.ipAddress, "10.0.0.0")
        XCTAssertEqual(endpoint1??.port, 53)
        XCTAssertEqual(endpoint1??.addressType, .IPv4)
        
        let endpoint2 = ((try? Endpoint(endpointString: "[2001:db8:a0b:12f0::1]:21")) as Endpoint??)
        XCTAssertEqual(endpoint2??.ipAddress, "2001:db8:a0b:12f0::1")
        XCTAssertEqual(endpoint2??.port, 21)
        XCTAssertEqual(endpoint2??.addressType, .IPv6)
    }
    
}
