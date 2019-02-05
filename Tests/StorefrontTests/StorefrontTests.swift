import Storefront
import XCTest

class StorefrontTests: XCTestCase {
    func testInit() {
        let store = Storefront(product: "product.identifier")
        XCTAssert(store.productIdentifier == "product.identifier")
    }
}
