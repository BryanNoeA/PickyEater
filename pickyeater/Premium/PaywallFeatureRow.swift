import SwiftUI

struct PaywallFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .semibold))
                Text(description).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PaywallFeatureRow(
        icon: "mappin.and.ellipse",
        color: .red,
        title: "Nearby Restaurants",
        description: "See real places matching your spin result"
    )
    .padding()
}
