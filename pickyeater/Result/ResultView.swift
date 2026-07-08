import SwiftUI

struct ResultView: View {
    let category: FoodCategory
    @Binding var showPaywall: Bool
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // ── Top row: drag handle + Spin Again ────────────────────
                ZStack {
                    // Drag handle centred
                    Capsule()
                        .fill(Color(.tertiaryLabel))
                        .frame(width: 36, height: 5)
                        .frame(maxWidth: .infinity)

                    // Spin Again pinned to the right
                    HStack {
                        Spacer()
                        Button("Spin Again", action: spinAgain)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)

                // ── Hero card ─────────────────────────────────────────────
                ResultHeroCard(category: category)

                // ── Share button ──────────────────────────────────────────
                ResultShareButton(category: category)

                // ── Nearby restaurants ────────────────────────────────────
                ResultNearbySection(category: category, onUpgrade: upgrade)

                Spacer(minLength: 20)
            }
            .padding(.top, 8)
        }
        .background(Color.peBackground)
        .presentationBackground(Color.peBackground)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }

    private func spinAgain() { dismiss() }

    private func upgrade() {
        dismiss()
        showPaywall = true
    }
}

#Preview {
    Color.peBackground.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ResultView(category: .sushi, showPaywall: .constant(false))
                .environment(StoreKitManager())
                .environment(FilterSettings())
        }
}
