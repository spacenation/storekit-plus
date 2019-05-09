import Foundation

public protocol StorefrontDelegate: AnyObject {
    func handleStore(event: Storefront.Event)
}

extension Storefront {
    public enum Event {
        case productRequestStarted, productRequestCompleted, productRequestFailed
        case purchaseStarted, purchaseCompleted, purchaseFailed
        case restoreStarted, restoreCompleted, restoreFailed
        case transactionStarted, transactionCompleted, transactionFailed, transactionCanceled
    }

    /// Adds delegate to an array if delegate is new.
    public func add(delegate: StorefrontDelegate) {
        if !delegates.contains(where: { $0 === delegate }) {
            delegates.append(delegate)
            print("Delegates", delegates.count)
        }
    }

    /// Remover delegate from the array.
    /// Delegate is responsible for deleting itself with this method call.
    public func remove(delegate: StorefrontDelegate) {
        if let index = delegates.firstIndex(where: { $0 === delegate }) {
            delegates.remove(at: index)
            print("Delegates", delegates.count)
        }
    }
}
