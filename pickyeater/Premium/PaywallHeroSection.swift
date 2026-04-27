import SwiftUI

struct PaywallHeroSection: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 110, height: 110)
                Text("📍")
                    .font(.system(size: 52))
                    .accessibilityHidden(true)
            }
            .padding(.top, 32)

            Text("Picky Eater Premium")
                .font(.system(size: 28, weight: .black))

            Text("Find real restaurants near you after every spin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    PaywallHeroSection()
}
