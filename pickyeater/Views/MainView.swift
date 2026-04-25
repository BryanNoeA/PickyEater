import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        @Bindable var state = appState

        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    SpinToggleView(spinMode: $state.spinMode)

                    SpinnerContainerView(
                        spinMode: $state.spinMode,
                        isSpinning: appState.isSpinning
                    ) { result in
                        appState.lastResult = result
                        appState.isSpinning = false
                        saveResult(result)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            appState.showResult = true
                        }
                    }
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
                        appState.showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            appState.showFeedMe = true
                        } label: {
                            Image(systemName: "fork.knife")
                        }
                        Button {
                            appState.showHistory = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                }
            }
            .sheet(isPresented: $state.showResult) {
                if let result = appState.lastResult {
                    ResultView(category: result)
                        .environment(appState)
                }
            }
            .sheet(isPresented: $state.showHistory) {
                HistoryView()
                    .environment(appState)
            }
            .sheet(isPresented: $state.showSettings) {
                SettingsView()
                    .environment(appState)
                    .environment(storeKit)
            }
            .sheet(isPresented: $state.showFeedMe) {
                FeedMeView()
                    .environment(appState)
            }
        }
    }

    private var spinButton: some View {
        Button {
            guard !appState.isSpinning else { return }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            appState.isSpinning = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: appState.spinMode == .wheel ? "arrow.trianglehead.2.clockwise" : "dice.fill")
                    .font(.system(size: 18, weight: .bold))
                Text(appState.spinMode == .wheel ? "Spin!" : "Roll!")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                appState.isSpinning
                    ? Color.gray
                    : Color.accentColor,
                in: RoundedRectangle(cornerRadius: 18)
            )
            .padding(.horizontal, 32)
        }
        .disabled(appState.isSpinning)
        .animation(.easeInOut(duration: 0.2), value: appState.isSpinning)
    }

    private func saveResult(_ category: FoodCategory) {
        let result = SpinResult(category: category, spinMode: appState.spinMode)
        modelContext.insert(result)
    }
}
