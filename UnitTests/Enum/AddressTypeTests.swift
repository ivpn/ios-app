import XCTest

@testable import IVPNClient

class AddressTypeTests: XCTestCase {
    
    func test_validateIpAddress() {
        let ipAddress1 = "127.0.0.1"
        let ipAddress2 = "::1"
        let ipAddress3 = "-"
        
        XCTAssertEqual(AddressType.validateIpAddress(ipToValidate: ipAddress1), .IPv4)
        XCTAssertEqual(AddressType.validateIpAddress(ipToValidate: ipAddress2), .IPv6)
        XCTAssertEqual(AddressType.validateIpAddress(ipToValidate: ipAddress3), .other)
    }
    
}
