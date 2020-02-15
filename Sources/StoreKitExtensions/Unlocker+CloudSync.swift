import Foundation

extension Unlocker {
    /// Cloud Storage
    public func setupCloudStorage() {
        NotificationCenter.default.addObserver(self, selector: #selector(cloudStorageDidChangeExternally), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: self.cloudStorage)
        syncPurchaseToCloudStorage()
        cloudStorageDidChangeExternally()
    }

    private func syncPurchaseToCloudStorage() {
        if userOwnsProduct == true {
            print("Saving purchase to Cloud Storage")
            NSUbiquitousKeyValueStore.default.set(true, forKey: "unlocked")
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }

    @objc
    func cloudStorageDidChangeExternally() {
        if !userOwnsProduct && NSUbiquitousKeyValueStore.default.bool(forKey: "unlocked") == true {
            syncSuccessfulPurchaseFromOtherDevice()
            print("Cloud storage updated elsewhere")
        }
    }

    private func syncSuccessfulPurchaseFromOtherDevice() {
        savePurchase(identifier: self.productIdentifier)
        self.userOwnsProduct = true
        DispatchQueue.main.async { self.state = .restoreCompleted }
    }
}
