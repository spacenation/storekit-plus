import Foundation
import StoreKit

extension Storefront {
    enum Identifier: String {
        case product
    }

    public func buyProduct() {
        print("Store: Buy Product request")
        if isProcessingProductsPurchase {
            print("Another purchase request is already sent.")
            return
        }

        DispatchQueue.main.async { self.state = .purchaseStarted }

        guard SKPaymentQueue.canMakePayments() else {
            print("Purchase Prohibited")
            DispatchQueue.main.async { self.state = .purchaseFailed }
            return
        }

        if let product = self.product {
            print("Purchase Request \(product)")
            isProcessingProductsPurchase = true
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(SKPayment(product: product) as SKPayment)
            DispatchQueue.main.async { self.state = .transactionStarted }
        }
    }

    public func savePurchase(identifier: String) {
        UserDefaults.standard.set(identifier, forKey: Identifier.product.rawValue)
    }
}
