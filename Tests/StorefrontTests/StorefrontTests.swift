import Storefront
import XCTest

class StorefrontTests: XCTestCase {
    func testInit() {
        XCTAssert(Storefront.version == "1.0.0")
    }
}
