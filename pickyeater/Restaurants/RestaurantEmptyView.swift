import SwiftUI

struct RestaurantEmptyView: View {
    let categoryName: String

    var body: some View {
        Label("No \(categoryName) restaurants found nearby.", systemImage: "magnifyingglass")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.vertical, 12)
    }
}

#Preview {
    RestaurantEmptyView(categoryName: "Sushi")
        .padding()
}
