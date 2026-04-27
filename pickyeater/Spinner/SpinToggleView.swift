import SwiftUI

/// Wheel / Dice mode picker — warm pill style matching the design system.
///
/// Active pill: persimmon-soft background with dark persimmon label.
/// Inactive: transparent with muted warm-gray label.
struct SpinToggleView: View {
    @Binding var spinMode: SpinMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SpinMode.allCases, id: \.self) { mode in
                pillButton(for: mode)
            }
        }
        .padding(4)
        .background(
            Color(red: 0.957, green: 0.929, blue: 0.894),
            in: Capsule()
        )
    }

    private func pillButton(for mode: SpinMode) -> some View {
        let isActive = spinMode == mode
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { spinMode = mode }
        } label: {
            HStack(spacing: 6) {
                Text(mode == .wheel ? "✦" : "⚀")
                    .font(.system(size: 13))
                Text(mode == .wheel ? "Spin Wheel" : "Dice")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(
                isActive
                    ? Color.persimmonDark
                    : Color(red: 0.541, green: 0.482, blue: 0.416)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                isActive ? Color.persimmonSoft : Color.clear,
                in: Capsule()
            )
        }
        .accessibilityLabel(mode.displayName)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 20) {
        SpinToggleView(spinMode: .constant(.wheel))
        SpinToggleView(spinMode: .constant(.dice))
    }
    .padding()
    .background(Color.peBackground)
}
