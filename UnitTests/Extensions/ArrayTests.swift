import XCTest

@testable import IVPNClient

class ArrayTests: XCTestCase {
    
    let array = [1, 2]
    
    func test_safeSubscript() {
        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 1], 2)
        XCTAssertEqual(array[safe: 2], nil)
    }
    
    func test_next() {
        let hostNames = ["1.1.1.1", "2.2.2.2"]
        
        if let nextHost = hostNames.next(item: "1.1.1.1") {
            XCTAssertEqual(nextHost, "2.2.2.2")
        } else {
            XCTFail("Next element not found")
        }
        
        XCTAssertNil(hostNames.next(item: "2.2.2.2"), "There should be no next element")
    }
    
    func test_move() {
        var hostNames = ["ivpn.net", "1.1.1.1", "2.2.2.2"]
        
        hostNames.move("ivpn.net", to: 0)
        XCTAssertEqual(hostNames, ["ivpn.net", "1.1.1.1", "2.2.2.2"])
        
        hostNames.move("1.1.1.1", to: 0)
        XCTAssertEqual(hostNames, ["1.1.1.1", "ivpn.net", "2.2.2.2"])
        
        hostNames.move("2.2.2.2", to: 0)
        XCTAssertEqual(hostNames, ["2.2.2.2", "1.1.1.1", "ivpn.net"])
    }
    
}
