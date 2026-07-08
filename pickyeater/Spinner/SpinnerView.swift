import SwiftUI
import SwiftData

struct SpinnerView: View {
    @State private var viewModel = SpinnerViewModel()
    @AppStorage("spinMode") private var spinMode: SpinMode = .wheel
    @Environment(StoreKitManager.self)  private var storeKit
    @Environment(FilterSettings.self)   private var filterSettings
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Color.peBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Custom toolbar ────────────────────────────────────────
                HStack {
                    HStack(spacing: 10) {
                        ToolbarIconButton(
                            systemImage: "slider.horizontal.3",
                            label: "Filter",
                            isActive: filterSettings.isActive,
                            badge: filterSettings.isActive ? 1 : 0,
                            action: openFilter
                        )
                        ToolbarIconButton(
                            systemImage: "clock",
                            label: "History",
                            action: openHistory
                        )
                        ToolbarIconButton(
                            systemImage: "fork.knife",
                            label: "Feed Me",
                            action: openFeedMe
                        )
                    }
                    Spacer()
                    ToolbarIconButton(
                        systemImage: "gearshape",
                        label: "Settings",
                        action: openSettings
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // ── Title ─────────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text("Picky Eater")
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                        .foregroundStyle(Color.peTextPrimary)
                    Text("What sounds good today?")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.peTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                // ── Mode toggle ───────────────────────────────────────────
                SpinToggleView(spinMode: $spinMode)
                    .disabled(viewModel.isSpinning)
                    .padding(.horizontal, 20)

                // ── Wheel / Dice ──────────────────────────────────────────
                Group {
                    switch spinMode {
                    case .wheel:
                        WheelView(isSpinning: viewModel.isSpinning) { result in
                            viewModel.handleResult(result, spinMode: spinMode, context: modelContext)
                        }
                    case .dice:
                        DiceView(isSpinning: viewModel.isSpinning) { result in
                            viewModel.handleResult(result, spinMode: spinMode, context: modelContext)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: spinMode)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 8)

                // ── CTA ───────────────────────────────────────────────────
                SpinButton(isSpinning: viewModel.isSpinning, onTap: spin)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        // Hide the navigation bar — title lives inline in the content
        .toolbarVisibility(.hidden, for: .navigationBar)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 1.0), trigger: viewModel.isSpinning) { _, new in new }
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.lastResult) { old, new in new != nil && old != new }
        .sheet(item: Bindable(viewModel).lastResult) { result in
            ResultView(category: result, showPaywall: Bindable(viewModel).showPaywall)
                .environment(storeKit)
        }
        .sheet(isPresented: Bindable(viewModel).showPaywall) {
            PaywallView()
                .environment(storeKit)
        }
        .sheet(isPresented: Bindable(viewModel).showHistory) {
            HistoryView()
        }
        .sheet(isPresented: Bindable(viewModel).showSettings) {
            SettingsView(showPaywall: Bindable(viewModel).showPaywall)
                .environment(storeKit)
        }
        .sheet(isPresented: Bindable(viewModel).showFeedMe) {
            FeedMeView()
        }
        .sheet(isPresented: Bindable(viewModel).showFilter) {
            FilterView()
                .environment(filterSettings)
        }
    }

    // MARK: - Actions

    private func spin()         { viewModel.startSpin() }
    private func openFilter()   { viewModel.showFilter   = true }
    private func openHistory()  { viewModel.showHistory  = true }
    private func openFeedMe()   { viewModel.showFeedMe   = true }
    private func openSettings() { viewModel.showSettings = true }
}

#Preview {
    NavigationStack {
        SpinnerView()
            .environment(StoreKitManager())
            .environment(FilterSettings())
    }
    .modelContainer(for: SpinResult.self, inMemory: true)
}
