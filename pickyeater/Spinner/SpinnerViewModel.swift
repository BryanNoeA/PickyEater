import SwiftUI
import SwiftData

@Observable
final class SpinnerViewModel {
    var isSpinning: Bool = false
    var lastResult: FoodCategory? = nil
    var showResult: Bool = false
    var showHistory: Bool = false
    var showSettings: Bool = false
    var showFeedMe: Bool = false
    var showPaywall: Bool = false

    func startSpin() {
        guard !isSpinning else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        isSpinning = true
    }

    func handleResult(_ category: FoodCategory, spinMode: SpinMode, context: ModelContext) {
        lastResult = category
        isSpinning = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        context.insert(SpinResult(category: category, spinMode: spinMode))
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showResult = true
        }
    }
}
