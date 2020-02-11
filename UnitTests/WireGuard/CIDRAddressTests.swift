import XCTest

@testable import IVPNClient

class CIDRAddressTests: XCTestCase {
    
    func testEndpoint() {
        let address1 = ((try? CIDRAddress(stringRepresentation: "10.0.0.0/0")) as CIDRAddress??)
        XCTAssertEqual(address1??.ipAddress, "10.0.0.0")
        XCTAssertEqual(address1??.subnet, 0)
        XCTAssertEqual(address1??.subnetString, "0.0.0.0")
        XCTAssertEqual(address1??.addressType, .IPv4)
        
        let address2 = ((try? CIDRAddress(stringRepresentation: "2001:db8:a0b:12f0::1/64")) as CIDRAddress??)
        XCTAssertEqual(address2??.ipAddress, "2001:db8:a0b:12f0::1")
        XCTAssertEqual(address2??.subnet, 64)
        XCTAssertEqual(address2??.addressType, .IPv6)
    }
    
}
