import SwiftUI
import SwiftData

struct SpinnerView: View {
    @State private var viewModel = SpinnerViewModel()
    @AppStorage("spinMode") private var spinMode: SpinMode = .wheel
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                SpinToggleView(spinMode: $spinMode)

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

                spinButton
                    .padding(.bottom, 8)
            }
            .padding(.top, 8)
        }
        .navigationTitle("Picky Eater")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
                .accessibilityLabel("Settings")
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        viewModel.showFeedMe = true
                    } label: {
                        Image(systemName: "fork.knife")
                    }
                    .accessibilityLabel("Feed Me")
                    Button {
                        viewModel.showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .accessibilityLabel("History")
                }
            }
        }
        .sheet(isPresented: Bindable(viewModel).showResult) {
            if let result = viewModel.lastResult {
                ResultView(category: result, showPaywall: Bindable(viewModel).showPaywall)
                    .environment(storeKit)
            }
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
    }

    private var spinButton: some View {
        Button {
            viewModel.startSpin()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: spinMode == .wheel ? "arrow.trianglehead.2.clockwise" : "dice.fill")
                    .font(.system(size: 18, weight: .bold))
                Text(spinMode == .wheel ? "Spin!" : "Roll!")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                viewModel.isSpinning ? Color.gray : Color.accentColor,
                in: RoundedRectangle(cornerRadius: 18)
            )
            .padding(.horizontal, 32)
        }
        .disabled(viewModel.isSpinning)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSpinning)
        .accessibilityLabel(spinMode == .wheel ? "Spin the wheel" : "Roll the dice")
    }
}

#Preview {
    NavigationStack {
        SpinnerView()
            .environment(StoreKitManager())
    }
    .modelContainer(for: SpinResult.self, inMemory: true)
}
