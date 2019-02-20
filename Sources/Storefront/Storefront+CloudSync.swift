import Foundation

extension Storefront {
    /// Cloud Storage
    func setupCloudStorage() {
        NotificationCenter.default.addObserver(self, selector: #selector(cloudStorageDidChangeExternally), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: self.cloudStorage)
        syncPurchaseToCloudStorage()
        cloudStorageDidChangeExternally()
    }

    private func syncPurchaseToCloudStorage() {
        if userHasProduct == true {
            print("Saving purchase to Cloud Storage")
            NSUbiquitousKeyValueStore.default.set(true, forKey: "unlimited")
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }

    @objc
    func cloudStorageDidChangeExternally() {
        if !userHasProduct && NSUbiquitousKeyValueStore.default.bool(forKey: "unlimited") == true {
            syncSuccessfulPurchaseFromOtherDevice()
            print("Cloud storage updated elsewhere to Unlimited")
        }
    }

    private func syncSuccessfulPurchaseFromOtherDevice() {
        savePurchase(identifier: self.productIdentifier)
        DispatchQueue.main.async { self.delegates.forEach { $0.handleStore(event: .restoreCompleted) } }
    }
}
