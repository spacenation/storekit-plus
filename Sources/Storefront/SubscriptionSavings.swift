import Foundation
import StoreKit

public struct SubscriptionSavings {
    public let percentSavings: Decimal
    public let granularPrice: Decimal
    public let granularPricePeriod: Product.SubscriptionPeriod.Unit
    
    public init(percentSavings: Decimal, granularPrice: Decimal, granularPricePeriod: Product.SubscriptionPeriod.Unit) {
        self.percentSavings = percentSavings
        self.granularPrice = granularPrice
        self.granularPricePeriod = granularPricePeriod
    }
    
    public var formattedPercent: String {
        return percentSavings.formatted(.percent.precision(.significantDigits(3)))
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public func formattedPrice(for subscription: Product) -> String {
        let currency = granularPrice.formatted(subscription.priceFormatStyle)
        let period = granularPricePeriod.formatted(subscription.subscriptionPeriodUnitFormatStyle)
        return "\(currency)/\(period)"
    }
}
