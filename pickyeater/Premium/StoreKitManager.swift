import StoreKit

@Observable
final class StoreKitManager {
    static let premiumProductID = "com.bryanalmejo.pickyeater.premium"

    var product: Product? = nil
    var isPurchased: Bool = false

    private var transactionListenerTask: Task<Void, Never>? = nil

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [StoreKitManager.premiumProductID])
            product = products.first
        } catch {
            // Non-fatal: paywall shows without a localized price
        }
    }

    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == StoreKitManager.premiumProductID {
                isPurchased = true
                return
            }
        }
        isPurchased = false
    }

    @discardableResult
    func purchase() async -> PurchaseState {
        guard let product else { return .failed }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPurchased = true
                    return .success
                }
                return .failed
            case .userCancelled:
                return .cancelled
            case .pending:
                // Ask-to-buy / SCA: not a failure. The transaction listener
                // flips isPurchased once the pending purchase clears.
                return .pending
            @unknown default:
                return .failed
            }
        } catch {
            return .failed
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
        } catch {
            // Non-fatal
        }
    }

    func startTransactionListener() {
        transactionListenerTask?.cancel()
        transactionListenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == StoreKitManager.premiumProductID {
                        self.isPurchased = transaction.revocationDate == nil
                    }
                }
            }
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }
}
