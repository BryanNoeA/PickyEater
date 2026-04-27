import Foundation

@Observable
final class PaywallViewModel {
    var isPurchasing: Bool  = false
    var isRestoring: Bool   = false
    var errorMessage: String? = nil

    /// Completes a StoreKit purchase and writes the result to Supabase.
    ///
    /// - Parameters:
    ///   - storeKit: Handles the actual App Store payment.
    ///   - profileManager: Updated on success so premium is tied to the account.
    ///   - userID: The signed-in user's UUID. If nil, premium is device-only
    ///             (shouldn't happen since PaywallView gates on sign-in).
    func purchase(
        storeKit: StoreKitManager,
        profileManager: ProfileManager,
        userID: UUID?
    ) async {
        errorMessage  = nil
        isPurchasing  = true

        await storeKit.purchase()

        if storeKit.isPurchased {
            // StoreKit confirmed the purchase — now write it to the user's
            // Supabase profile so it unlocks on all their devices
            if let userID {
                await profileManager.setPremium(true, userID: userID)
            }
        } else {
            errorMessage = "Purchase could not be completed. Please try again."
        }

        isPurchasing = false
    }

    /// Restores a previous StoreKit purchase and syncs premium to Supabase.
    func restore(
        storeKit: StoreKitManager,
        profileManager: ProfileManager,
        userID: UUID?
    ) async {
        errorMessage = nil
        isRestoring  = true

        await storeKit.restorePurchases()

        if storeKit.isPurchased {
            if let userID {
                await profileManager.setPremium(true, userID: userID)
            }
        } else {
            errorMessage = "No previous purchase found for this Apple ID."
        }

        isRestoring = false
    }
}
