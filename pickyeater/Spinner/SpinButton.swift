import SwiftUI

/// Full-width "Pick for me" CTA — persimmon pill with glow shadow.
///
/// Grays out while the wheel or dice is animating to prevent double-taps.
struct SpinButton: View {
    let isSpinning: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("Pick for me")
                .font(.headline)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    isSpinning ? Color.gray.opacity(0.5) : Color.accentColor,
                    in: Capsule()
                )
                .shadow(
                    color: isSpinning
                        ? .clear
                        : Color.persimmon.opacity(0.35),
                    radius: 12, y: 6
                )
        }
        .disabled(isSpinning)
        .animation(.easeInOut(duration: 0.2), value: isSpinning)
        .accessibilityLabel("Pick a food category for me")
    }
}

#Preview {
    VStack(spacing: 20) {
        SpinButton(isSpinning: false, onTap: {})
        SpinButton(isSpinning: true, onTap: {})
    }
    .padding(24)
    .background(Color.peBackground)
}
