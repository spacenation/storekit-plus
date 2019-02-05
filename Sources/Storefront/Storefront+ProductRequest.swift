import Foundation
import StoreKit

extension Storefront: SKProductsRequestDelegate {
    /// Starts an SKProducts request with the given product identifiers
    ///
    /// - parameter identifiers: An array of String uniquely identifying the product
    public func requestProduct() {
        guard !userHasProduct, !isProcessingProductsRequest else {
            return
        }

        delegates.forEach { $0.handleStore(event: .productRequestStarted) }

        isProcessingProductsRequest = true
        self.productRequest = SKProductsRequest(productIdentifiers: Set([productIdentifier]))
        self.productRequest?.delegate = self
        self.productRequest?.start()
    }

    /// SKProductsRequestDelegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        isProcessingProductsRequest = false
        if response.products.isEmpty {
            if initialProductRequest == true {
                initialProductRequest = false
            } else {
                delegates.forEach { $0.handleStore(event: .productRequestFailed) }
            }
        } else {
            product = response.products.first
            delegates.forEach { $0.handleStore(event: .productRequestCompleted) }
            /// Restore products
            //restoreProducts()
        }
        productRequest = nil
    }

    @objc
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        isProcessingProductsRequest = false
        if initialProductRequest == true {
            initialProductRequest = false
        } else {
            delegates.forEach { $0.handleStore(event: .productRequestFailed) }
        }
        productRequest = nil
    }
}
