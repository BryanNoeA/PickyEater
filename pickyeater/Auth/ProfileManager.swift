import Foundation
import Supabase

/// Manages the current user's Supabase profile row and premium status.
///
/// `isPremium` is cached in UserDefaults so the app works gracefully offline —
/// the last known value is used when Supabase can't be reached. The cache is
/// refreshed on every sign-in and cleared on every sign-out.
@Observable
@MainActor
final class ProfileManager {

    // MARK: - State

    /// The live profile fetched from Supabase. Nil until the user signs in
    /// and the first fetch completes.
    var profile: UserProfile? = nil

    /// True while a network request is in flight.
    var isLoading: Bool = false

    /// Whether this account has premium access.
    ///
    /// ⚠️ TESTING MODE — hardcoded to true so all features are accessible.
    /// Before shipping, replace this line with:
    ///   var isPremium: Bool = UserDefaults.standard.bool(forKey: "cachedIsPremium") {
    ///       didSet { UserDefaults.standard.set(isPremium, forKey: "cachedIsPremium") }
    ///   }
    var isPremium: Bool = true

    // MARK: - Profile loading

    /// Fetches the profile for the given user. Called each time auth state changes.
    func loadProfile(for userID: UUID) async {
        isLoading = true

        do {
            let fetched: UserProfile = try await SupabaseConfig.client
                .from("profiles")
                .select()
                .eq("id", value: userID.uuidString)
                .single()
                .execute()
                .value

            profile   = fetched
            // ⚠️ TESTING MODE — not syncing isPremium from Supabase.
            // Before shipping, restore this line:
            //   isPremium = fetched.isPremium

        } catch {
            // Profile row not found — the Supabase trigger should have created it,
            // but as a safety net we insert one manually if it's missing.
            await createProfileIfNeeded(for: userID)
        }

        isLoading = false
    }

    /// Inserts a blank profile row. Runs on first sign-in if the trigger missed it
    /// (e.g. a timing race during account creation).
    private func createProfileIfNeeded(for userID: UUID) async {
        let payload = NewProfile(id: userID)
        try? await SupabaseConfig.client
            .from("profiles")
            .insert(payload)
            .execute()

        // Set a minimal local profile so the rest of the app works immediately
        profile = UserProfile(id: userID, isPremium: false)
    }

    // MARK: - Premium management

    /// Grants or revokes premium on this Supabase account.
    /// Called after a successful StoreKit purchase (grant = true) or if a
    /// refund is detected (grant = false).
    func setPremium(_ grant: Bool, userID: UUID) async {
        let payload = PremiumUpdate(isPremium: grant)
        do {
            try await SupabaseConfig.client
                .from("profiles")
                .update(payload)
                .eq("id", value: userID.uuidString)
                .execute()

            isPremium       = grant
            profile?.isPremium = grant

        } catch {
            // If the write fails (e.g. offline), update locally only.
            // On next launch while online the UI will re-sync from Supabase.
            isPremium = grant
        }
    }

    /// Migration helper for users who purchased premium BEFORE account sign-in
    /// was added to the app. If their StoreKit receipt says "purchased" but
    /// their Supabase profile says "free", we automatically upgrade them.
    func migrateStoreKitPurchaseIfNeeded(storeKitIsPurchased: Bool, userID: UUID) async {
        guard storeKitIsPurchased,
              let profile,
              !profile.isPremium else { return }

        await setPremium(true, userID: userID)
    }

    // MARK: - Sign-out / account deletion

    /// Clears all cached state. Called on sign-out so premium features lock
    /// immediately on this device.
    func clearCache() {
        profile   = nil
        isPremium = false   // also writes false to UserDefaults via didSet
    }

    /// Deletes the user's profile row from Supabase.
    ///
    /// This satisfies App Review's account-deletion requirement (the user's
    /// personal data is removed). The `auth.users` record is deleted on the
    /// server via a Supabase Edge Function or the database CASCADE rule.
    func deleteProfileData(for userID: UUID) async throws {
        try await SupabaseConfig.client
            .from("profiles")
            .delete()
            .eq("id", value: userID.uuidString)
            .execute()

        clearCache()
    }
}
