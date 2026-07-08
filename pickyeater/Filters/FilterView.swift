import SwiftUI

/// Filter sheet — lets the user narrow down restaurant results
/// before they appear in the result card.
struct FilterView: View {
    @Environment(FilterSettings.self) private var filters
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ── Top row: drag handle + Done ───────────────────────────
                SheetTopBar {
                    Button("Done") { dismiss() }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }

                // ── Title ─────────────────────────────────────────────────
                Text("Filters")
                    .font(.system(.title, design: .serif).weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                // ── Open Now card ─────────────────────────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    Toggle("Open Now", isOn: Bindable(filters).openNow)
                        .font(.headline)
                        .padding(16)

                    Divider()
                        .padding(.horizontal, 16)

                    Text("Apple Maps doesn't provide live hours, so results may include places that are closed. Tap any result to verify current hours in Maps.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 14)
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)

                // ── Search Radius card ────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Search Radius")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(filters.radiusMiles)) mi")
                            .foregroundStyle(Color.accentColor)
                            .monospacedDigit()
                            .fontWeight(.semibold)
                    }

                    Slider(value: Bindable(filters).radiusMiles, in: 5...30, step: 1)
                        .tint(Color.accentColor)

                    HStack {
                        Text("5 mi").font(.caption2).foregroundStyle(.tertiary)
                        Spacer()
                        Text("30 mi").font(.caption2).foregroundStyle(.tertiary)
                    }

                    Text("Restaurants within \(Int(filters.radiusMiles)) mile\(filters.radiusMiles == 1 ? "" : "s") of your current location.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)

                // ── Reset ─────────────────────────────────────────────────
                if filters.isActive {
                    Button("Reset to Defaults", role: .destructive, action: reset)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
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
    }

    // MARK: - Actions

    private func reset() { filters.reset() }
}

#Preview {
    Color.peBackground.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            FilterView()
                .environment(FilterSettings())
        }
}
