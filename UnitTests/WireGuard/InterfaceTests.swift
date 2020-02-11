import XCTest

@testable import IVPNClient

class InterfaceTests: XCTestCase {
    
    var interface = Interface()
    
    func testGeneratePrivateKey() {
        interface.privateKey = Interface.generatePrivateKey()
        XCTAssertEqual(interface.privateKey?.count, 44)
        XCTAssertFalse(interface.privateKey?.isEmpty ?? true)
    }
    
    func testPublicKey() {
        interface.privateKey = "+CRaGBKzRDMBCrkP6ETC8CzzASl97v1oZtMcfo/9pFg="
        XCTAssertEqual(interface.publicKey, "zIbn7AoBFkQg6uKvw3RupKUTK5H1cnJFeaZTXdyh8Fc=")
    }
    
    func testInitWithDictionary() {
        let interface = Interface(["ip_address": "10.0.0.1"])
        XCTAssertEqual(interface?.addresses, "10.0.0.1")
    }
    
}
