import SwiftUI

/// Shared sheet top bar: centered drag handle with an optional trailing action.
struct SheetTopBar<Trailing: View>: View {
    @ViewBuilder var trailing: () -> Trailing

    init(@ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.trailing = trailing
    }

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color(.tertiaryLabel))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)

            HStack {
                Spacer()
                trailing()
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
    }
}

#Preview {
    VStack {
        SheetTopBar {
            Button("Done") {}
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.accentColor)
        }
        SheetTopBar()
    }
}
