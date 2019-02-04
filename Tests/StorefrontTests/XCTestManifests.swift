import XCTest

extension StorefrontTests {
    static let __allTests = [
        ("testInit", testInit),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StorefrontTests.__allTests),
    ]
}
#endif
