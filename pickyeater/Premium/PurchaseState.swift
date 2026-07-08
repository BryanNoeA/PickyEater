import Foundation

/// Outcome of a StoreKit purchase attempt, distinguishing ask-to-buy/SCA
/// pending approval from an outright failure.
enum PurchaseState {
    case success
    case pending
    case cancelled
    case failed
}
