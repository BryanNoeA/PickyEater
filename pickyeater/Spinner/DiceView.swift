import SwiftUI

struct DiceView: View {
    let isSpinning: Bool
    let onResult: (FoodCategory) -> Void

    @State private var displayCategory: FoodCategory = FoodCategory.allCases.randomElement()!
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var scale: Double = 1.0
    @State private var isAnimating: Bool = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var hapticTrigger: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(displayCategory.color.gradient)
                .shadow(color: displayCategory.color.opacity(0.5), radius: 20, y: 8)

            VStack(spacing: 8) {
                Text(displayCategory.emoji)
                    .font(.system(size: 72))
                Text(displayCategory.displayName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 220, height: 220)
        .scaleEffect(scale)
        .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Food dice showing \(displayCategory.displayName)")
        .accessibilityHint("Roll to get a random food category")
        .onChange(of: isSpinning) { _, spinning in
            if spinning && !isAnimating { roll() }
        }
    }

    private func roll() {
        isAnimating = true
        timerTask?.cancel()

        withAnimation(.easeIn(duration: 0.25)) {
            rotationX = 360
            rotationY = 180
        }

        timerTask = Task {
            for _ in 0..<12 {
                try? await Task.sleep(for: .milliseconds(90))
                guard !Task.isCancelled else { return }
                displayCategory = FoodCategory.allCases.randomElement()!
            }

            let finalCategory = FoodCategory.allCases.randomElement()!
            displayCategory = finalCategory

            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                rotationX = 0
                rotationY = 0
                scale = 1.15
            }
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                scale = 1.0
            }

            hapticTrigger.toggle()
            isAnimating = false
            onResult(finalCategory)
        }
    }
}

#Preview {
    DiceView(isSpinning: false, onResult: { _ in })
        .padding(40)
}
