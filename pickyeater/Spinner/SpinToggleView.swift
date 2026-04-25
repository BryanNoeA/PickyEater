import SwiftUI

struct SpinToggleView: View {
    @Binding var spinMode: SpinMode

    var body: some View {
        Picker("Mode", selection: $spinMode) {
            ForEach(SpinMode.allCases, id: \.self) { mode in
                Label(
                    mode.displayName,
                    systemImage: mode == .wheel ? "circle.grid.3x3.fill" : "dice.fill"
                )
                .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 32)
    }
}

#Preview {
    SpinToggleView(spinMode: .constant(.wheel))
        .padding()
}
