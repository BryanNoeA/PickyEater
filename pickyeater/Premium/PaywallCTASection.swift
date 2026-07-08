import SwiftUI
import StoreKit

struct PaywallCTASection: View {
    let isPurchasing: Bool
    let isRestoring: Bool
    let isPending: Bool
    let product: Product?
    let onPurchase: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onPurchase) {
                Group {
                    if isPending {
                        Label("Waiting for approval", systemImage: "clock.fill")
                            .font(.headline)
                    } else if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(product.map { "Unlock for \($0.displayPrice)" } ?? "Unlock Premium")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
            }
            .disabled(isPurchasing || isRestoring || isPending)
            .accessibilityLabel(isPending ? "Waiting for approval" : (product.map { "Unlock Premium for \($0.displayPrice)" } ?? "Unlock Premium"))

            Button(action: onRestore) {
                Group {
                    if isRestoring {
                        ProgressView()
                    } else {
                        Text("Restore Purchase")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .disabled(isPurchasing || isRestoring || isPending)

            Text("One-time purchase · No subscription · No expiry")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

#Preview {
    PaywallCTASection(
        isPurchasing: false,
        isRestoring: false,
        isPending: false,
        product: nil,
        onPurchase: {},
        onRestore: {}
    )
}
