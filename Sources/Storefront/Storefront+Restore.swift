import Foundation
import StoreKit

extension Storefront {
    public func restoreProducts() {
        print("Restore In-App Purchases")
        delegates.forEach { $0.handleStore(event: .restoreStarted) }

        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Transaction Failed")
        delegates.forEach { $0.handleStore(event: .restoreFailed) }
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Restore Complete")
    }
}
