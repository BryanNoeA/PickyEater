import SwiftUI

struct ResultView: View {
    let category: FoodCategory
    @Binding var showPaywall: Bool
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    heroCard
                    shareButton
                    nearbySection
                    Spacer(minLength: 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Your Pick!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Spin Again") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(spacing: 12) {
            Text(category.emoji)
                .font(.system(size: 88))
                .accessibilityHidden(true)

            Text("You're having…")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(category.displayName)
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(category.color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(category.color.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("You're having \(category.displayName)")
    }

    private var shareButton: some View {
        ShareLink(
            item: "I'm having \(category.emoji) \(category.displayName) today! Found with Picky Eater 🎲",
            subject: Text("My lunch pick!")
        ) {
            Label("Share Your Pick", systemImage: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
        .tint(.primary)
    }

    @ViewBuilder
    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(storeKit.isPurchased ? category.color : .secondary)
                Text("Nearby \(category.displayName)")
                    .font(.headline)
                if !storeKit.isPurchased {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)

            if storeKit.isPurchased {
                RestaurantListView(category: category)
                    .padding(.horizontal, 20)
            } else {
                Button {
                    dismiss()
                    showPaywall = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Find real nearby restaurants")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("Unlock Picky Eater Premium")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(category.color.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .accessibilityLabel("Unlock Premium to find nearby restaurants")
            }
        }
    }
}

#Preview {
    ResultView(category: .sushi, showPaywall: .constant(false))
        .environment(StoreKitManager())
}
