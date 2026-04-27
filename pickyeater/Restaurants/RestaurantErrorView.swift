import SwiftUI

struct RestaurantErrorView: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "location.slash")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.vertical, 12)
    }
}

#Preview {
    RestaurantErrorView(message: "Location access denied.")
        .padding()
}
