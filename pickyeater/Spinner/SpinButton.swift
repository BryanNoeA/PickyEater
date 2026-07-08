import SwiftUI

/// Full-width "Pick for me" CTA — persimmon Liquid Glass pill.
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
        }
        .buttonStyle(.glassProminent)
        .tint(isSpinning ? Color.gray.opacity(0.5) : Color.persimmon)
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
