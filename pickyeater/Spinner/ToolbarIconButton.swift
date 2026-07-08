import SwiftUI

/// Circular bordered icon button used in SpinnerView's custom toolbar.
///
/// Matches the design system: 38 pt circle, material background,
/// warm hairline border, subtle shadow. Pass `isActive` to tint the
/// icon in persimmon when a feature is turned on (e.g. filter badge).
struct ToolbarIconButton: View {
    let systemImage: String
    let label: String
    var isActive: Bool = false
    var badge: Int = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isActive ? Color.accentColor : Color.primary)
                .frame(width: 38, height: 38)
                .background(.regularMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(
                            Color(red: 0.925, green: 0.882, blue: 0.824),
                            lineWidth: 0.5
                        )
                }
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                // Badge — shown when filters are active
                .overlay(alignment: .topTrailing) {
                    if badge > 0 {
                        Text("\(badge)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 18, minHeight: 18)
                            .padding(.horizontal, 4)
                            .background(Color.accentColor, in: Capsule())
                            .offset(x: 4, y: -4)
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    HStack(spacing: 12) {
        ToolbarIconButton(systemImage: "slider.horizontal.3", label: "Filter", action: {})
        ToolbarIconButton(systemImage: "slider.horizontal.3", label: "Filter active", isActive: true, badge: 1, action: {})
        ToolbarIconButton(systemImage: "clock", label: "History", action: {})
        ToolbarIconButton(systemImage: "fork.knife", label: "Feed Me", action: {})
        ToolbarIconButton(systemImage: "gearshape", label: "Settings", action: {})
    }
    .padding()
    .background(Color.peBackground)
}
