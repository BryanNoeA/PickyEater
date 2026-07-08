import SwiftUI
import StoreKit

struct PaywallView: View {
    @State private var viewModel = PaywallViewModel()
    @Environment(StoreKitManager.self)  private var storeKit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    PaywallHeroSection()
                    PaywallFeatureList()

                    // Ask-to-buy / SCA approval pending — informational, not an error
                    if viewModel.isPending, let message = viewModel.errorMessage {
                        Label(message, systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    } else if let error = viewModel.errorMessage {
                        // Error from a failed purchase attempt
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    PaywallCTASection(
                        isPurchasing: viewModel.isPurchasing,
                        isRestoring:  viewModel.isRestoring,
                        product:      storeKit.product,
                        onPurchase:   purchase,
                        onRestore:    restore
                    )
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
        // Dismiss paywall once purchase is confirmed
        .onChange(of: storeKit.isPurchased) { _, isPurchased in
            if isPurchased { dismiss() }
        }
    }

    // MARK: - Actions

    private func purchase() {
        Task {
            await viewModel.purchase(storeKit: storeKit)
        }
    }

    private func restore() {
        Task {
            await viewModel.restore(storeKit: storeKit)
        }
    }

    private func close() { dismiss() }
}

#Preview {
    PaywallView()
        .environment(StoreKitManager())
}
