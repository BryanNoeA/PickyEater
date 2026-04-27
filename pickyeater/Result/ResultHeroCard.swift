import SwiftUI

struct ResultHeroCard: View {
    let category: FoodCategory

    var body: some View {
        VStack(spacing: 12) {
            Text(category.emoji)
                .font(.system(size: 88))
                .accessibilityHidden(true)

            Text("You're having…")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(category.displayName)
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(category.color.opacity(0.4), lineWidth: 1.5)
        }
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("You're having \(category.displayName)")
    }
}

#Preview {
    ResultHeroCard(category: .sushi)
        .padding()
}
