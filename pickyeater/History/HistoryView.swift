import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SpinResult.timestamp, order: .reverse) private var results: [SpinResult]

    var body: some View {
        NavigationStack {
            Group {
                if results.isEmpty {
                    ContentUnavailableView(
                        "No Spins Yet",
                        systemImage: "dice",
                        description: Text("Your spin history will appear here.")
                    )
                } else {
                    List {
                        ForEach(results) { result in
                            if let category = result.category {
                                historyRow(result: result, category: category)
                            }
                        }
                        .onDelete(perform: deleteResults)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !results.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear All", role: .destructive) { clearAll() }
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    private func historyRow(result: SpinResult, category: FoodCategory) -> some View {
        HStack(spacing: 12) {
            Text(category.emoji)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .background(category.color.opacity(0.1), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.system(size: 15, weight: .semibold))
                Text(result.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: result.spinMode == SpinMode.wheel.rawValue ? "circle.grid.3x3.fill" : "dice.fill")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.displayName), \(result.timestamp.formatted(.relative(presentation: .named)))")
    }

    private func deleteResults(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(results[index]) }
    }

    private func clearAll() {
        results.forEach { modelContext.delete($0) }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: SpinResult.self, inMemory: true)
}
