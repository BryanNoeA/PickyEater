import SwiftUI

struct RestaurantLoadingView: View {
    let categoryName: String

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                ProgressView()
                Text("Finding nearby \(categoryName)…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

#Preview {
    RestaurantLoadingView(categoryName: "Sushi")
}
