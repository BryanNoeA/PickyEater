import SwiftUI

struct ResultShareButton: View {
    let category: FoodCategory

    var body: some View {
        ShareLink(
            item: "I'm having \(category.emoji) \(category.displayName) today! Found with Picky Eater 🎲",
            subject: Text("My lunch pick!")
        ) {
            Label("Share Your Pick", systemImage: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
        .tint(.primary)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ResultShareButton(category: .sushi)
        .padding()
}
