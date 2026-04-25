import SwiftUI

struct SpinnerContainerView: View {
    @Binding var spinMode: SpinMode
    let isSpinning: Bool
    let onResult: (FoodCategory) -> Void

    var body: some View {
        Group {
            switch spinMode {
            case .wheel:
                WheelView(isSpinning: isSpinning, onResult: onResult)
            case .dice:
                DiceView(isSpinning: isSpinning, onResult: onResult)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: spinMode)
    }
}
