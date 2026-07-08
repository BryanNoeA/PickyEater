import Foundation

@Observable
final class PaywallViewModel {
    var isPurchasing: Bool  = false
    var isRestoring: Bool   = false
    var errorMessage: String? = nil
    var isPending: Bool = false

    /// Completes a StoreKit purchase. `StoreKitManager.isPurchased` is the
    /// single source of truth for premium — no account sync needed.
    func purchase(storeKit: StoreKitManager) async {
        errorMessage  = nil
        isPending     = false
        isPurchasing  = true

        switch await storeKit.purchase() {
        case .success, .cancelled:
            break
        case .pending:
            isPending = true
            errorMessage = "Awaiting approval… you'll get Pro as soon as it's confirmed."
        case .failed:
            errorMessage = "Purchase could not be completed. Please try again."
        }

        isPurchasing = false
    }

    /// Restores a previous StoreKit purchase.
    func restore(storeKit: StoreKitManager) async {
        errorMessage = nil
        isRestoring  = true

        await storeKit.restorePurchases()

        if !storeKit.isPurchased {
            errorMessage = "No previous purchase found for this Apple ID."
        }

        isRestoring = false
    }
}
