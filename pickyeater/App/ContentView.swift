import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(AuthManager.self) private var authManager
    @Environment(ProfileManager.self) private var profileManager

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SpinnerView()
        }
        // ── Profile sync ──────────────────────────────────────────────────
        // This task reruns whenever the signed-in user changes.
        // When the user signs in:  fetches profile, refreshes isPremium cache
        // When the user signs out: no-op (cache is cleared explicitly in AccountView)
        // When app launches with a restored session: runs automatically
        .task(id: authManager.currentUserID) {
            guard let userID = authManager.currentUserID else { return }

            await profileManager.loadProfile(for: userID)

            // If the user purchased premium via StoreKit before accounts
            // existed in this app, automatically grant them Supabase premium
            await profileManager.migrateStoreKitPurchaseIfNeeded(
                storeKitIsPurchased: storeKit.isPurchased,
                userID: userID
            )
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreKitManager())
        .environment(AuthManager())
        .environment(ProfileManager())
        .environment(FilterSettings())
        .modelContainer(for: SpinResult.self, inMemory: true)
}
