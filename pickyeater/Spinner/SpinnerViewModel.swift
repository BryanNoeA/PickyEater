import SwiftUI
import SwiftData

@Observable
final class SpinnerViewModel {
    var isSpinning: Bool = false
    var lastResult: FoodCategory? = nil
    var showHistory: Bool = false
    var showSettings: Bool = false
    var showFeedMe: Bool = false
    var showPaywall: Bool = false
    var showFilter: Bool = false

    func startSpin() {
        guard !isSpinning else { return }
        isSpinning = true
    }

    func handleResult(_ category: FoodCategory, spinMode: SpinMode, context: ModelContext) {
        lastResult = category
        isSpinning = false
        context.insert(SpinResult(category: category, spinMode: spinMode))
    }
}
