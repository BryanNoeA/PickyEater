import SwiftUI
import UIKit

struct RestaurantErrorView: View {
    let message: String
    /// True when `message` is specifically a location-permission denial —
    /// swaps the retry affordance for a direct link to Settings, since
    /// retrying can't fix a permission the user has to change themselves.
    var showsOpenSettings: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Label(message, systemImage: "location.slash")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if showsOpenSettings {
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    RestaurantErrorView(message: "Location access is disabled. Enable it in Settings to find nearby restaurants.", showsOpenSettings: true)
        .padding()
}

#Preview("Generic error") {
    RestaurantErrorView(message: "Couldn't load restaurants. Check your connection and try again.")
        .padding()
}
