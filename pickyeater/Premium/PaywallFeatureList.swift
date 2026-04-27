import SwiftUI

struct PaywallFeatureList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PaywallFeatureRow(
                icon: "mappin.and.ellipse",
                color: .red,
                title: "Nearby Restaurants",
                description: "See real places matching your spin result"
            )
            PaywallFeatureRow(
                icon: "arrow.triangle.turn.up.right.diamond.fill",
                color: .blue,
                title: "One-Tap Directions",
                description: "Open Apple Maps directly to your restaurant"
            )
            PaywallFeatureRow(
                icon: "infinity",
                color: .orange,
                title: "Unlock Forever",
                description: "One-time purchase, no subscription"
            )
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    PaywallFeatureList()
}
