import Foundation
import StoreKit

public class Unlocker: NSObject, ObservableObject {
    public enum State {
        case idle
        case productRequestStarted, productRequestCompleted, productRequestFailed
        case purchaseStarted, purchaseCompleted, purchaseFailed
        case restoreStarted, restoreCompleted, restoreFailed
        case transactionStarted, transactionCompleted, transactionFailed, transactionCanceled
    }
    
    #if os(OSX)
    // MARK: - Receipt
    public class var hasReceipt: Bool {
        if let path = Bundle.main.appStoreReceiptURL?.path {
            return FileManager().fileExists(atPath: path)
        }
        return false
    }
    #endif

    public internal(set) var product: SKProduct? {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    public internal(set) var userOwnsProduct: Bool {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    @Published public internal(set) var state: State = .idle

    public var productIdentifier: String
    
    var initialProductRequest: Bool = true
    /// An optional instance of SKProductsRequest
    var productRequest: SKProductsRequest?

    /// A Bool value identifying if the product request in still in process
    var isProcessingProductsRequest = false
    /// A Bool value identifying if the product purchase in still in process
    var isProcessingProductsPurchase = false
    
    let cloudStorage = NSUbiquitousKeyValueStore()

    public init(product identifier: String) {
        print("Store: Init")
        productIdentifier = identifier
        self.userOwnsProduct = UserDefaults.standard.string(forKey: Identifier.product.rawValue) == identifier
        
        super.init()
        print("Product", userOwnsProduct)
        setupCloudStorage()
    }
}

public extension SKProduct {
    /// Converts a price based on locale
    ///
    /// - returns: The price on String format based on current locale
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? self.price.stringValue
    }
}
