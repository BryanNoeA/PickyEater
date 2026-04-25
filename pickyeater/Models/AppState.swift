import Foundation

@Observable
final class AppState {
    var spinMode: SpinMode = .wheel
    var isPremium: Bool = false
    var isSpinning: Bool = false
    var lastResult: FoodCategory? = nil
    var showResult: Bool = false
    var showPaywall: Bool = false
    var showHistory: Bool = false
    var showSettings: Bool = false
    var showFeedMe: Bool = false
}

enum SpinMode: String, CaseIterable {
    case wheel
    case dice

    var displayName: String {
        switch self {
        case .wheel: return "Wheel"
        case .dice: return "Dice"
        }
    }
}
