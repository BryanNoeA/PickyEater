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
            // Product load failure is non-fatal; paywall will show without a price
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

    func purchase(appState: AppState) async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPurchased = true
                    appState.isPremium = true
                    appState.showPaywall = false
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            // Purchase errors are surfaced to the UI via isPurchased remaining false
        }
    }

    func restorePurchases(appState: AppState) async {
        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
            if isPurchased {
                appState.isPremium = true
                appState.showPaywall = false
            }
        } catch {
            // Restore failure is non-fatal
        }
    }

    func startTransactionListener(appState: AppState) {
        transactionListenerTask?.cancel()
        transactionListenerTask = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == StoreKitManager.premiumProductID {
                        let owned = transaction.revocationDate == nil
                        isPurchased = owned
                        appState.isPremium = owned
                    }
                }
            }
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }
}
