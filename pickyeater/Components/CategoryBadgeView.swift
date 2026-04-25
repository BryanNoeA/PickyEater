import SwiftUI

struct CategoryBadgeView: View {
    let category: FoodCategory
    var fontSize: CGFloat = 15

    var body: some View {
        HStack(spacing: 6) {
            Text(category.emoji)
                .font(.system(size: fontSize))
            Text(category.displayName)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(category.color, in: Capsule())
    }
}
