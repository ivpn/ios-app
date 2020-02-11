import XCTest

@testable import IVPNClient

class StringTests: XCTestCase {
    
    func testCommaSeparatedStringFrom() {
        XCTAssertEqual(String.commaSeparatedStringFrom(elements: ["a", "b", "c"]), "a,b,c")
    }
    
    func testCommaSeparatedToArray() {
        XCTAssertEqual("a,b,c".commaSeparatedToArray(), ["a", "b", "c"])
        XCTAssertEqual("a, b, c".commaSeparatedToArray(), ["a", "b", "c"])
    }
    
    func testTrim() {
        let user1 = "  username  "
        let user2 = " user name "
        let user3 = "username"
        
        XCTAssertEqual(user1.trim(), "username")
        XCTAssertEqual(user2.trim(), "user name")
        XCTAssertEqual(user3.trim(), "username")
    }
    
    func testBase64KeyToHex() {
        XCTAssertEqual("=".base64KeyToHex(), nil)
        XCTAssertEqual("+CRaGBKzRDMBCrkP6ETC8CzzASl97v1oZtMcfo/9pFg=".base64KeyToHex(), "f8245a1812b34433010ab90fe844c2f02cf301297deefd6866d31c7e8ffda458")
    }
    
    func testCamelCaseToCapitalized() {
        XCTAssertEqual("dnsFailure".camelCaseToCapitalized(), "Dns Failure")
        XCTAssertEqual("tlsServerVerification".camelCaseToCapitalized(), "Tls Server Verification")
        XCTAssertEqual("authentication".camelCaseToCapitalized(), "Authentication")
    }
    
}
