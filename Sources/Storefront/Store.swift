import Foundation
@_exported import StoreKit

public typealias Transaction = StoreKit.Transaction
public typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
public typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

@MainActor public final class Store: ObservableObject {
    public enum PurchaseFinishedAction {
        case dismissStore
        case noAction
        case displayError
    }
    
    private let productIdentifiers: Set<String>
    
    @Published public private(set) var nonConsumables: [Product]
    @Published public private(set) var subscriptions: [Product]
    
    @Published public private(set) var purchasedNonConsumables: [Product] = []
    @Published public private(set) var purchasedSubscriptions: [Product] = []
    
    @Published public private(set) var purchasedProductIdentifiers: Set<String>
    
    @Published public private(set) var purchaseError: (any LocalizedError)?

    ///
    private var lastLoadError: Error?
    
    private var productLoadingTask: Task<Void, Never>?
    private var transactionUpdatesTask: Task<Void, Never>?
    private var statusUpdatesTask: Task<Void, Never>?
    private var storefrontUpdatesTask: Task<Void, Never>?
    private let userDefaults: UserDefaults

    public init(productIdentifiers: Set<String>, userDefaults: UserDefaults = .standard) {
        self.productIdentifiers = productIdentifiers
        self.userDefaults = userDefaults
        let purchasedProductsArray = userDefaults.object(forKey: "purchasedProducts") as? [String]
        self.purchasedProductIdentifiers = Set(purchasedProductsArray ?? [])
        print("Persisted Purchased Products:", Set(purchasedProductsArray ?? []))
        
        nonConsumables = []
        subscriptions = []
        
        setupListenerTasksIfNecessary()
        
        Task(priority: .background) {
            //During store initialization, request products from the App Store.
            await self.requestProducts()
            
            //Deliver products that the customer purchases.
            await self.updateCustomerProductStatus()
        }
    }
    
    deinit {
        productLoadingTask?.cancel()
        transactionUpdatesTask?.cancel()
        statusUpdatesTask?.cancel()
        storefrontUpdatesTask?.cancel()
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedNonConsumables: [Product] = []
        var purchasedSubscriptions: [Product] = []

        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                //Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .nonConsumable:
                    if let nonConsumable = nonConsumables.first(where: { $0.id == transaction.productID }) {
                        purchasedNonConsumables.append(nonConsumable)
                    }
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                print("Transaction failed verification")
            }
        }

        //Update the store information with the purchased products.
        self.purchasedNonConsumables = purchasedNonConsumables

        //Update the store information with auto-renewable subscription products.
        self.purchasedSubscriptions = purchasedSubscriptions
        
        //Update locally persisted identifiers
        let purchasedProductIdentifiers = (purchasedNonConsumables + purchasedSubscriptions).map { $0.id }
        self.purchasedProductIdentifiers = Set(purchasedProductIdentifiers)
        userDefaults.set(purchasedProductIdentifiers, forKey: "purchasedProducts")
        print("Updated Purchased Products:", Set(purchasedProductIdentifiers))
    }
    
    public func removePersistedPurchasedProducts() {
        userDefaults.removeObject(forKey: "purchasedProducts")
    }
    
    public func purchase(option product: Product) async -> PurchaseFinishedAction {
        let action: PurchaseFinishedAction
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                //Check whether the transaction is verified. If it isn't,
                //this function rethrows the verification error.
                let transaction = try checkVerified(verification)

                //The transaction is verified. Deliver content to the user.
                await updateCustomerProductStatus()

                //Always finish a transaction.
                await transaction.finish()
                action = .dismissStore
            case .pending:
                print("Purchase pending user action")
                action = .noAction
            case .userCancelled:
                print("User cancelled purchase")
                action = .noAction
            @unknown default:
                print("Unknown result: \(result)")
                action = .noAction
            }
        } catch let error as LocalizedError {
            purchaseError = error
            action = .displayError
        } catch {
            print("Purchase failed: \(error)")
            action = .noAction
        }
        return action
    }
    
    private func setupListenerTasksIfNecessary() {
        if transactionUpdatesTask == nil {
            transactionUpdatesTask = Task(priority: .background) {
                for await result in Transaction.updates {
                    do {
                        let transaction = try self.checkVerified(result)

                        //Deliver products to the user.
                        await self.updateCustomerProductStatus()

                        //Always finish a transaction.
                        await transaction.finish()
                    } catch {
                        //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                        print("Transaction failed verification")
                    }
                }
            }
        }
        if statusUpdatesTask == nil {
            statusUpdatesTask = Task(priority: .background) {
                for await update in Product.SubscriptionInfo.Status.updates {
                    do {
                        let transaction = try self.checkVerified(update.transaction)
                        let _ = try self.checkVerified(update.renewalInfo)

                        //Deliver products to the user.
                        await self.updateCustomerProductStatus()

                        //Always finish a transaction.
                        await transaction.finish()
                    } catch {
                        //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                        print("Transaction failed verification")
                    }
                }
            }
        }
        if storefrontUpdatesTask == nil {
            storefrontUpdatesTask = Task(priority: .background) {
                for await update in Storefront.updates {
                    print("Storefront changed to \(update)")
                    // Cancel existing loading task if necessary.
                    if let task = productLoadingTask {
                        task.cancel()
                    }
                    // Load products again.
                    productLoadingTask = Task(priority: .utility) {
                        await self.requestProducts()
                    }
                }
            }
        }
    }
    
    private func requestProducts() async {
        do {
            //Request products from the App Store using the identifiers.
            let storeProducts = try await Product.products(for: productIdentifiers)

            var newNonConsumable: [Product] = []
            var newSubscriptions: [Product] = []

            //Filter the products into categories based on their type.
            for product in storeProducts {
                switch product.type {
                case .nonConsumable:
                    newNonConsumable.append(product)
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    //Ignore this product.
                    print("Unknown product")
                }
            }

            //Sort each product category by price, lowest to highest, to update the store.
            nonConsumables = sortByPrice(newNonConsumable)
            subscriptions = sortByPrice(newSubscriptions)
        } catch {
            print("Failed to get in-app products: \(error)")
            lastLoadError = error
        }
        productLoadingTask = nil
    }
    
    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
}

public extension Transaction {
    var isRevoked: Bool {
        // The revocation date is never in the future.
        revocationDate != nil
    }
}

public extension Product {
    var subscriptionInfo: Product.SubscriptionInfo {
        subscription.unsafelyUnwrapped
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    var priceText: String {
        "\(self.displayPrice)/\(self.subscriptionInfo.subscriptionPeriod.unit.localizedDescription.lowercased())"
    }
}
