import SwiftUI

struct RestaurantEmptyView: View {
    let categoryName: String

    var body: some View {
        VStack(spacing: 4) {
            Label("No \(categoryName) restaurants found nearby.", systemImage: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Try widening your search radius in Filters.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    RestaurantEmptyView(categoryName: "Sushi")
        .padding()
}
