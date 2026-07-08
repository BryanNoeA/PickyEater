import SwiftUI

struct ResultNearbySection: View {
    let category: FoodCategory
    let onUpgrade: () -> Void

    @Environment(StoreKitManager.self) private var storeKit

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(storeKit.isPurchased ? Color.accentColor : .secondary)
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
                // Premium user: show the real restaurant list from MapKit
                RestaurantListView(category: category)
                    .padding(.horizontal, 20)
            } else {
                // Free user: show an upgrade prompt
                Button(action: onUpgrade) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Find real nearby restaurants")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Unlock Picky Eater Premium")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(category.color.opacity(0.3), lineWidth: 1)
                    }
                }
                .padding(.horizontal, 20)
                .accessibilityLabel("Unlock Premium to find nearby restaurants")
            }
        }
    }
}

#Preview {
    ResultNearbySection(category: .sushi, onUpgrade: {})
        .environment(StoreKitManager())
}
