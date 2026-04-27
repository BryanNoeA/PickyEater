import SwiftUI
import StoreKit

struct PaywallView: View {
    @State private var viewModel = PaywallViewModel()
    @Environment(StoreKitManager.self)  private var storeKit
    @Environment(AuthManager.self)      private var authManager
    @Environment(ProfileManager.self)   private var profileManager
    @Environment(\.dismiss) private var dismiss

    /// Controls the AuthView sheet. When the user taps "Create Account to Unlock",
    /// this becomes true and the sign-in flow slides up.
    @State private var showAuth = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    PaywallHeroSection()
                    PaywallFeatureList()

                    // Error from a failed purchase attempt
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // If the user is signed in, show the purchase button.
                    // If not, show the account-creation gate instead.
                    if authManager.isSignedIn {
                        PaywallCTASection(
                            isPurchasing: viewModel.isPurchasing,
                            isRestoring:  viewModel.isRestoring,
                            product:      storeKit.product,
                            onPurchase:   purchase,
                            onRestore:    restore
                        )
                    } else {
                        PaywallAuthGate(onSignIn: showAuthSheet)
                    }
                }
            }
            .navigationTitle("Go Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark.circle.fill", action: close)
                        .foregroundStyle(.secondary)
                }
            }
        }
        // Dismiss paywall once purchase is confirmed and isPremium updates
        .onChange(of: profileManager.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
        // Sign-in sheet — presented when user taps the auth gate
        .sheet(isPresented: $showAuth) {
            AuthView()
        }
    }

    // MARK: - Actions

    private func purchase() {
        Task {
            await viewModel.purchase(
                storeKit: storeKit,
                profileManager: profileManager,
                userID: authManager.currentUserID
            )
        }
    }

    private func restore() {
        Task {
            await viewModel.restore(
                storeKit: storeKit,
                profileManager: profileManager,
                userID: authManager.currentUserID
            )
        }
    }

    private func close()         { dismiss() }
    private func showAuthSheet() { showAuth = true }
}

#Preview {
    PaywallView()
        .environment(StoreKitManager())
        .environment(AuthManager())
        .environment(ProfileManager())
}
