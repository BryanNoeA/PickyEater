import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SpinResult.timestamp, order: .reverse) private var results: [SpinResult]
    @State private var showClearConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ── Top row: drag handle + Clear All ─────────────────────
                SheetTopBar {
                    if !results.isEmpty {
                        Button("Clear All", role: .destructive) {
                            showClearConfirm = true
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.red)
                    }
                }

                // ── Title ─────────────────────────────────────────────────
                Text("History")
                    .font(.system(.title, design: .serif).weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                // ── Content ───────────────────────────────────────────────
                if results.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(results) { result in
                            if let category = result.category {
                                historyCard(result: result, category: category)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 8)
        }
        .background(Color.peBackground)
        .presentationBackground(Color.peBackground)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
        .confirmationDialog("Clear all history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear All", role: .destructive, action: clearAll)
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🎲")
                .font(.system(size: 56))
                .accessibilityHidden(true)
            Text("nothing yet — go spin")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Row card

    private func historyCard(result: SpinResult, category: FoodCategory) -> some View {
        HStack(spacing: 12) {
            Text(category.emoji)
                .font(.system(size: 28))
                .frame(width: 48, height: 48)
                .background(category.color.opacity(0.15), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.subheadline.weight(.semibold))
                Text(result.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: result.spinMode == SpinMode.wheel.rawValue
                  ? "circle.grid.3x3.fill" : "dice.fill")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.displayName), \(result.timestamp.formatted(.relative(presentation: .named)))")
    }

    // MARK: - Actions

    private func clearAll() {
        try? modelContext.delete(model: SpinResult.self)
    }
}

#Preview {
    Color.peBackground.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            HistoryView()
                .modelContainer(for: SpinResult.self, inMemory: true)
        }
}
