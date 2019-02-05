import Foundation
import StoreKit

extension Storefront: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction, isRestored: false)
            case .restored:
                complete(transaction: transaction, isRestored: true)
            case .failed:
                failed(transaction: transaction)
            default:
                return
            }
        }
    }

    /// Finalizes a completed transaction
    private func complete(transaction: SKPaymentTransaction, isRestored: Bool) {
        savePurchase(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)

        isProcessingProductsPurchase = false

        delegates.forEach { $0.handleStore(event: .transactionCompleted) }

        if isRestored {
            print("Store: Restored Purchase")
            delegates.forEach { $0.handleStore(event: .restoreCompleted) }
        } else {
            print("Store: Original Purchase")
            delegates.forEach { $0.handleStore(event: .purchaseCompleted) }
        }
    }

    /// Finalizes a failed transaction
    private func failed(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            switch error.code {
            case .paymentCancelled:
                print("Fail Cancelled")
                delegates.forEach { $0.handleStore(event: .transactionCanceled) }
                delegates.forEach { $0.handleStore(event: .transactionFailed) }
                delegates.forEach { $0.handleStore(event: .purchaseFailed) }

            default:
                print("Fail Error \(error) Code \(error.code)")
                delegates.forEach { $0.handleStore(event: .transactionFailed) }
                delegates.forEach { $0.handleStore(event: .purchaseFailed) }
            }
        }

        SKPaymentQueue.default().finishTransaction(transaction)
        isProcessingProductsPurchase = false
    }
}
