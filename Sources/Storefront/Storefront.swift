///
///  Copyright (c) 2013-2017 SpaceNation Inc.

import Foundation
import StoreKit

public class Storefront: NSObject {
    #if os(OSX)
    // MARK: - Receipt
    public class var hasReceipt: Bool {
        if let path = Bundle.main.appStoreReceiptURL?.path {
            return FileManager().fileExists(atPath: path)
        }
        return false
    }
    #endif

    public internal(set) var product: SKProduct?

    let cloudStorage = NSUbiquitousKeyValueStore()

    /// Delegates
    var delegates: [StorefrontDelegate] = []

    public var productIdentifier: String
    var initialProductRequest: Bool = true
    /// An optional instance of SKProductsRequest
    var productRequest: SKProductsRequest?

    /// A Bool value identifying if the product request in still in process
    var isProcessingProductsRequest = false
    /// A Bool value identifying if the product purchase in still in process
    var isProcessingProductsPurchase = false

    public init(product identifier: String) {
        print("Store: Init")
        productIdentifier = identifier
        super.init()
        print("Product", userHasProduct)
        setupCloudStorage()
    }
}

public extension SKProduct {
    /// Converts a price based on locale
    ///
    /// - returns: The price on String format based on current locale
    public func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? self.price.stringValue
    }
}
