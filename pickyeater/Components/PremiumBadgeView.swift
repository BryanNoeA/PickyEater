import SwiftUI

struct PremiumBadgeView: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(6)
            .background(.ultraThinMaterial, in: Circle())
    }
}
