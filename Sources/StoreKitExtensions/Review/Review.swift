#if os(iOS)
import Foundation
import UIKit
import StoreKit

public class Review: ObservableObject {
    static let key: String = "engagements"
    let id: String
    let engagementsThreshold: Int
    
    public internal(set) var engagements: Int {
        didSet {
            UserDefaults.standard.set(engagements, forKey: Self.key)
        }
    }
    
    public init(id: String, engagementsThreshold: Int) {
        self.id = id
        self.engagementsThreshold = engagementsThreshold
        self.engagements = UserDefaults.standard.integer(forKey: Self.key)
    }
    
    deinit {
        UserDefaults.standard.synchronize()
    }
}

public extension Review {
    func addEngagement(resetOnThreshold: Bool = false) {
        engagements += 1
        print("Review: engagements \(engagements), threshold \(engagementsThreshold)")
        if engagements >= engagementsThreshold {
            Self.requestReview()
            if resetOnThreshold {
                engagements = 0
            }
        }
    }
    
    func open() {
        Self.open(id: self.id)
    }
}

public extension Review {
    static func requestReview() {
        print("Review: request")
        SKStoreReviewController.requestReview()
    }
    
    static func open(id: String) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(id)?action=write-review") {
            UIApplication.shared.open(url, options: [:], completionHandler: { (status) in
                if status {
                    print("Review: open success")
                } else {
                    print("Review: open failed")
                }
            })
        }
    }
}
#endif
