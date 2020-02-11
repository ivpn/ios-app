import XCTest

@testable import IVPNClient

class PeerTests: XCTestCase {
    
    func testEndpoint() {
        let endpoint = Peer.endpoint(host: "10.0.0.0", port: 53)
        XCTAssertEqual(endpoint, "10.0.0.0:53")
    }
    
}
