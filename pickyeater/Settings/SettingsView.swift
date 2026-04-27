import SwiftUI

struct SettingsView: View {
    @Binding var showPaywall: Bool
    @Environment(StoreKitManager.self)  private var storeKit
    @Environment(AuthManager.self)      private var authManager
    @Environment(ProfileManager.self)   private var profileManager
    @Environment(\.dismiss) private var dismiss

    @State private var showAuth     = false
    @State private var isRestoring  = false

    var body: some View {
        NavigationStack {
            List {
                accountSection
                premiumSection
                legalSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: done)
                        .fontWeight(.semibold)
                }
            }
        }
        // Sign-in sheet — for non-premium users who tap "Sign In"
        .sheet(isPresented: $showAuth) {
            AuthView()
        }
    }

    // MARK: - Account section

    private var accountSection: some View {
        Section("Account") {
            if authManager.isSignedIn {
                // Signed in: show email + link to AccountView
                NavigationLink {
                    AccountView()
                } label: {
                    Label(authManager.currentUserEmail ?? "My Account", systemImage: "person.circle.fill")
                }
            } else {
                // Not signed in: prompt to sign in (required to access premium)
                Button(action: openAuth) {
                    Label("Sign In / Create Account", systemImage: "person.circle")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    // MARK: - Premium section

    private var premiumSection: some View {
        Section("Premium") {
            // Show premium status based on Supabase profile (with offline cache fallback)
            HStack {
                Label("Status", systemImage: "star.fill")
                    .foregroundStyle(profileManager.isPremium ? .yellow : .primary)
                Spacer()
                Text(profileManager.isPremium ? "Unlocked ✓" : "Free")
                    .font(.subheadline)
                    .foregroundStyle(profileManager.isPremium ? .yellow : .secondary)
            }

            if !profileManager.isPremium {
                // Upgrade button — requires sign-in, so redirect if not signed in
                Button(action: openUpgradeFlow) {
                    Text("Unlock Premium")
                        .foregroundStyle(Color.accentColor)
                }

                Button(action: restorePurchase) {
                    HStack {
                        Text("Restore Purchase")
                        if isRestoring { Spacer(); ProgressView() }
                    }
                }
                .disabled(isRestoring)
            }
        }
    }

    // MARK: - Legal section

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://example.com/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
        } header: {
            Text("Legal")
        } footer: {
            Text("Replace the privacy policy URL before submitting to the App Store.")
                .font(.caption)
        }
    }

    // MARK: - About section

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func done()           { dismiss() }
    private func openAuth()       { showAuth = true }

    private func openUpgradeFlow() {
        // If not signed in, show auth first — they need an account to purchase
        if authManager.isSignedIn {
            dismiss()
            showPaywall = true
        } else {
            showAuth = true
        }
    }

    private func restorePurchase() {
        Task {
            isRestoring = true
            await storeKit.restorePurchases()
            // If StoreKit confirms a purchase, sync it to their Supabase profile
            if storeKit.isPurchased, let userID = authManager.currentUserID {
                await profileManager.setPremium(true, userID: userID)
            }
            isRestoring = false
        }
    }
}

#Preview {
    SettingsView(showPaywall: .constant(false))
        .environment(StoreKitManager())
        .environment(AuthManager())
        .environment(ProfileManager())
}
