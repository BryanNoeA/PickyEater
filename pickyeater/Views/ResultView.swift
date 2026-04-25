import SwiftUI

struct ResultView: View {
    let category: FoodCategory
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Hero result card
                    VStack(spacing: 12) {
                        Text(category.emoji)
                            .font(.system(size: 88))

                        Text("You're having…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(category.displayName)
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(category.color)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(category.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 20)

                    // Share button
                    ShareLink(
                        item: "I'm having \(category.emoji) \(category.displayName) today! Found with Picky Eater 🎲",
                        subject: Text("My lunch pick!")
                    ) {
                        Label("Share Your Pick", systemImage: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20)
                    .tint(.primary)

                    // Restaurant search (premium)
                    nearbySection

                    Spacer(minLength: 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Your Pick!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Spin Again") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(appState.isPremium ? category.color : .secondary)
                Text("Nearby \(category.displayName)")
                    .font(.headline)
                if !appState.isPremium {
                    Spacer()
                    PremiumBadgeView()
                }
            }
            .padding(.horizontal, 20)

            if appState.isPremium {
                RestaurantListView(category: category)
                    .padding(.horizontal, 20)
            } else {
                Button {
                    dismiss()
                    appState.showPaywall = true
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
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(category.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
