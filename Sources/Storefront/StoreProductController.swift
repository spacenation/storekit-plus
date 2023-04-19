import Foundation
import StoreKit
import Combine

@MainActor
public final class StoreProductController: ObservableObject {
    @Published public internal(set) var product: Product?
    @Published public private(set) var isEntitled: Bool = false
    @Published public private(set) var purchaseError: Error?
    
    private let productIDs: Set<String>
    
    internal nonisolated init(identifiedBy productIDs: Set<String>) {
        self.productIDs = productIDs
        Task(priority: .background) {
            await self.updateEntitlement()
        }
    }
    
    public func purchase() async {
        guard let product = product else {
            print("Product has not loaded yet")
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try verificationResult.payloadValue
                self.isEntitled = true
                await transaction.finish()
            case .pending:
                print("Purchase pending user action")
            case .userCancelled:
                print("User cancelled purchase")
            @unknown default:
                print("Unknown result: \(result)")
            }
        } catch {
            purchaseError = error
        }
    }
    
    internal func set(isEntitled: Bool) {
        self.isEntitled = isEntitled
    }
    
    private func updateEntitlement() async {
        guard let productID = productIDs.first else {
            isEntitled = false
            return
        }
        
        switch await StoreKit.Transaction.currentEntitlement(for: productID) {
        case .verified: isEntitled = true
        case .unverified(_, let error):
            print("Unverified entitlement for \(productID): \(error)")
            fallthrough
        case .none: isEntitled = false
        }
    }
    
}
