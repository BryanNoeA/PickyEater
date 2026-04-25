import Foundation

@Observable
final class PaywallViewModel {
    var isPurchasing: Bool = false
    var isRestoring: Bool = false
    var errorMessage: String? = nil

    func purchase(storeKit: StoreKitManager) async {
        errorMessage = nil
        isPurchasing = true
        await storeKit.purchase()
        isPurchasing = false
        if !storeKit.isPurchased {
            errorMessage = "Purchase could not be completed. Please try again."
        }
    }

    func restore(storeKit: StoreKitManager) async {
        errorMessage = nil
        isRestoring = true
        await storeKit.restorePurchases()
        isRestoring = false
        if !storeKit.isPurchased {
            errorMessage = "No previous purchase found for this Apple ID."
        }
    }
}
