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
            VStack(spacing: 0) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                Spacer()
            }
            .zIndex(1)

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 2 - 4
                let count = Double(categories.count)

                for (index, category) in categories.enumerated() {
                    let startAngle = Angle(degrees: sliceAngle * Double(index) + rotationDegrees - 90)
                    let endAngle = Angle(degrees: sliceAngle * Double(index + 1) + rotationDegrees - 90)

                    var slicePath = Path()
                    slicePath.move(to: center)
                    slicePath.addArc(center: center, radius: radius,
                                     startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    slicePath.closeSubpath()
                    context.fill(slicePath, with: .color(category.color))
                    context.stroke(slicePath, with: .color(.white.opacity(0.6)), lineWidth: 1.5)

                    let midAngleDeg = sliceAngle * (Double(index) + 0.5) + rotationDegrees - 90
                    let midAngleRad = midAngleDeg * .pi / 180
                    let labelRadius = radius * 0.68
                    let labelPoint = CGPoint(
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

                var hubPath = Path()
                hubPath.addEllipse(in: CGRect(x: center.x - 18, y: center.y - 18, width: 36, height: 36))
                context.fill(hubPath, with: .color(.white))
                context.stroke(hubPath, with: .color(.gray.opacity(0.3)), lineWidth: 2)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(28)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Food category wheel")
            .accessibilityHint("Spin to pick a random food category")
        }
        .onChange(of: isSpinning) { _, spinning in
            if spinning && !isAnimating { spin() }
        }
    }

    private func spin() {
        isAnimating = true
        let target = rotationDegrees + Double.random(in: 720...1440)
        withAnimation(.interpolatingSpring(mass: 1.2, stiffness: 45, damping: 16)) {
            rotationDegrees = target
        }
        Task {
            try? await Task.sleep(for: .seconds(1.9))
            let normalized = rotationDegrees.truncatingRemainder(dividingBy: 360)
            let adjusted = (360 - normalized + sliceAngle / 2).truncatingRemainder(dividingBy: 360)
            let index = Int(adjusted / sliceAngle) % categories.count
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
