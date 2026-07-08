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
                SheetTopBar {
                    Button("Spin Again", action: spinAgain)
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                }

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
