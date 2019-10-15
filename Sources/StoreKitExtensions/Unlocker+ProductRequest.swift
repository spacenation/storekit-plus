import Foundation
import StoreKit

extension Unlocker: SKProductsRequestDelegate {
    /// Starts an SKProducts request with the given product identifiers
    ///
    /// - parameter identifiers: An array of String uniquely identifying the product
    public func requestProduct() {
        guard !userOwnsProduct, !isProcessingProductsRequest else {
            return
        }

        DispatchQueue.main.async { self.state = .productRequestStarted }

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
                DispatchQueue.main.async { self.state = .productRequestFailed }
            }
        } else {
            product = response.products.first
            DispatchQueue.main.async { self.state = .productRequestCompleted }
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
            DispatchQueue.main.async { self.state = .productRequestFailed }
        }
        productRequest = nil
    }
}
