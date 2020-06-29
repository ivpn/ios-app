import XCTest
import UIKit

@testable import IVPNClient

class NSMutableAttributedStringTests: XCTestCase {
    
    let label = UILabel()
    
    func test_bold() {
        let formattedString = NSMutableAttributedString()
        formattedString.bold("Bold text")
        
        label.attributedText = formattedString
        
        XCTAssertEqual(label.text, "Bold text")
    }
    
    func test_normal() {
        let formattedString = NSMutableAttributedString()
        formattedString.normal("Normal text")
        
        label.attributedText = formattedString
        
        XCTAssertEqual(label.text, "Normal text")
    }
    
}
