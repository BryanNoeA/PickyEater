import Foundation

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
