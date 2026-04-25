import SwiftUI

struct WheelView: View {
    let isSpinning: Bool
    let onResult: (FoodCategory) -> Void

    @State private var rotationDegrees: Double = 0
    @State private var isAnimating: Bool = false

    private let categories = FoodCategory.allCases
    private let sliceAngle: Double = 360.0 / Double(FoodCategory.allCases.count)

    var body: some View {
        ZStack {
            // Pointer at 12 o'clock
            VStack(spacing: 0) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                Spacer()
            }
            .zIndex(1)

            // The wheel
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 - 4
                let count = Double(categories.count)

                for (index, category) in categories.enumerated() {
                    let startAngle = Angle(degrees: sliceAngle * Double(index) + rotationDegrees - 90)
                    let endAngle = Angle(degrees: sliceAngle * Double(index + 1) + rotationDegrees - 90)

                    // Slice fill
                    var slicePath = Path()
                    slicePath.move(to: center)
                    slicePath.addArc(
                        center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false
                    )
                    slicePath.closeSubpath()
                    context.fill(slicePath, with: .color(category.color))

                    // Slice border
                    context.stroke(slicePath, with: .color(.white.opacity(0.6)), lineWidth: 1.5)

                    // Emoji + label at arc midpoint
                    let midAngleDeg = sliceAngle * (Double(index) + 0.5) + rotationDegrees - 90
                    let midAngleRad = midAngleDeg * .pi / 180
                    let labelRadius = radius * 0.68
                    let labelPoint = CGPoint(
                        x: center.x + labelRadius * cos(midAngleRad),
                        y: center.y + labelRadius * sin(midAngleRad)
                    )

                    // Draw emoji
                    let emojiText = Text(category.emoji)
                        .font(.system(size: max(10, radius / count * 1.1)))
                    context.draw(emojiText, at: CGPoint(x: labelPoint.x, y: labelPoint.y - 6))

                    // Draw name label
                    let nameText = Text(shortName(category))
                        .font(.system(size: max(7, radius / count * 0.8), weight: .semibold))
                        .foregroundStyle(.white)
                    context.draw(nameText, at: CGPoint(x: labelPoint.x, y: labelPoint.y + 8))
                }

                // Center hub
                var hubPath = Path()
                hubPath.addEllipse(in: CGRect(
                    x: center.x - 18, y: center.y - 18, width: 36, height: 36
                ))
                context.fill(hubPath, with: .color(.white))
                context.stroke(hubPath, with: .color(.gray.opacity(0.3)), lineWidth: 2)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(28) // room for pointer above
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Food category wheel. Spin to pick a random food category.")
        }
        .onChange(of: isSpinning) { _, spinning in
            if spinning && !isAnimating {
                spin()
            }
        }
    }

    private func spin() {
        isAnimating = true
        let extraRotation = Double.random(in: 720...1440)
        let target = rotationDegrees + extraRotation

        withAnimation(.interpolatingSpring(mass: 1.2, stiffness: 45, damping: 16)) {
            rotationDegrees = target
        }

        // Wait for spring to settle (~1.8s), then fire result
        let settleDuration = 1.9
        Task {
            try? await Task.sleep(for: .seconds(settleDuration))
            let normalizedAngle = rotationDegrees.truncatingRemainder(dividingBy: 360)
            // Pointer is at top (0° offset applied via -90° in draw), so we reverse-map
            let adjustedAngle = (360 - normalizedAngle + sliceAngle / 2)
                .truncatingRemainder(dividingBy: 360)
            let index = Int(adjustedAngle / sliceAngle) % categories.count
            let winningCategory = categories[max(0, min(index, categories.count - 1))]
            isAnimating = false
            onResult(winningCategory)
        }
    }

    private func shortName(_ category: FoodCategory) -> String {
        let name = category.displayName
        return name.count > 7 ? String(name.prefix(6)) + "…" : name
    }
}
