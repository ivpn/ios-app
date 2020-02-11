import XCTest
import UIKit

@testable import IVPNClient

class NSMutableAttributedStringTests: XCTestCase {
    
    let label = UILabel()
    
    func testBold() {
        let formattedString = NSMutableAttributedString()
        formattedString.bold("Bold text")
        
        label.attributedText = formattedString
        
        XCTAssertEqual(label.text, "Bold text")
    }
    
    func testNormal() {
        let formattedString = NSMutableAttributedString()
        formattedString.normal("Normal text")
        
        label.attributedText = formattedString
        
        XCTAssertEqual(label.text, "Normal text")
    }
    
}
