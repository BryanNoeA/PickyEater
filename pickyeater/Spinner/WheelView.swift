import SwiftUI

struct WheelView: View {
    let isSpinning: Bool
    let onResult: (FoodCategory) -> Void

    @State private var rotationDegrees: Double = 0
    @State private var isAnimating: Bool = false

    private let categories = FoodCategory.allCases
    private let sliceAngle: Double = 360.0 / Double(FoodCategory.allCases.count)

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 4
            let count  = Double(categories.count)

            // Draw slices at fixed angles — rotation is applied via
            // .rotationEffect() on the Canvas view so SwiftUI can
            // properly interpolate it during the animation.
            for (index, category) in categories.enumerated() {
                let startAngle = Angle(degrees: sliceAngle * Double(index) - 90)
                let endAngle   = Angle(degrees: sliceAngle * Double(index + 1) - 90)

                var slicePath = Path()
                slicePath.move(to: center)
                slicePath.addArc(center: center, radius: radius,
                                 startAngle: startAngle, endAngle: endAngle, clockwise: false)
                slicePath.closeSubpath()
                context.fill(slicePath, with: .color(category.color))
                // White dividers between slices — keeps the soft palette clean
                context.stroke(slicePath, with: .color(.white.opacity(0.9)), lineWidth: 2.5)

                let midAngleDeg = sliceAngle * (Double(index) + 0.5) - 90
                let midAngleRad = midAngleDeg * .pi / 180
                let labelRadius = radius * 0.68
                let labelPoint  = CGPoint(
                    x: center.x + labelRadius * cos(midAngleRad),
                    y: center.y + labelRadius * sin(midAngleRad)
                )

                context.draw(
                    Text(category.emoji).font(.system(size: max(10, radius / count * 1.1))),
                    at: CGPoint(x: labelPoint.x, y: labelPoint.y - 6)
                )
                context.draw(
                    Text(shortName(category))
                        .font(.system(size: max(7, radius / count * 0.8), weight: .semibold))
                        .foregroundStyle(.white),
                    at: CGPoint(x: labelPoint.x, y: labelPoint.y + 8)
                )
            }

            // Center hub — white circle that covers the slice tips
            var hubPath = Path()
            hubPath.addEllipse(in: CGRect(x: center.x - 22, y: center.y - 22, width: 44, height: 44))
            context.fill(hubPath, with: .color(.white))
            context.stroke(hubPath, with: .color(Color(red: 0.937, green: 0.902, blue: 0.855).opacity(0.8)), lineWidth: 2)
        }
        // rotationEffect is a proper SwiftUI-animatable modifier —
        // withAnimation can interpolate it smoothly across frames.
        .rotationEffect(.degrees(rotationDegrees))
        .aspectRatio(1, contentMode: .fit)
        // Top padding creates space for the pointer. Sides + bottom add breathing room.
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, 36)
        // Pointer overlaid directly on the Canvas so it always tracks the wheel's
        // actual position — not a separate VStack that can drift when the parent
        // frame is taller than the wheel.
        .overlay(alignment: .top) {
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(Color.persimmon)
                .shadow(color: Color.persimmon.opacity(0.35), radius: 4, y: 2)
                // Offset pushes the tip to sit right at the wheel's 12 o'clock edge.
                // 36pt top padding − 24pt icon height = 12pt so tip lands at the rim.
                .offset(y: 12)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Food category wheel")
        .accessibilityHint("Spin to pick a random food category")
        .onChange(of: isSpinning) { _, spinning in
            if spinning && !isAnimating { spin() }
        }
    }

    // How long the spin animation runs before the result is delivered.
    private let spinDuration: Double = 3.5

    private func spin() {
        isAnimating = true

        // 4–7 full rotations plus a random offset so the wheel always
        // lands in a different spot — keeps it feeling genuinely random.
        let fullRotations = Double.random(in: 4...7) * 360
        let randomOffset  = Double.random(in: 0..<360)
        let target = rotationDegrees + fullRotations + randomOffset

        // easeOut gives a fast start that decelerates naturally into the
        // landing position, mimicking the physics of a real spinning wheel.
        withAnimation(.easeOut(duration: spinDuration)) {
            rotationDegrees = target
        }

        Task {
            // Wait for the animation to fully settle before reading the result.
            try? await Task.sleep(for: .seconds(spinDuration + 0.1))

            // The pointer sits at 12 o'clock (270° in standard math coords,
            // but we offset by -90° in the canvas draw, so 0° in our system).
            // Work out which slice index is under the pointer after the spin.
            let normalized = rotationDegrees.truncatingRemainder(dividingBy: 360)
            let adjusted   = (360 - normalized + sliceAngle / 2).truncatingRemainder(dividingBy: 360)
            let index      = Int(adjusted / sliceAngle) % categories.count

            isAnimating = false
            onResult(categories[max(0, min(index, categories.count - 1))])
        }
    }

    private func shortName(_ category: FoodCategory) -> String {
        let name = category.displayName
        return name.count > 7 ? String(name.prefix(6)) + "…" : name
    }
}

#Preview {
    WheelView(isSpinning: false, onResult: { _ in })
        .frame(width: 340, height: 380)
        .padding()
}
