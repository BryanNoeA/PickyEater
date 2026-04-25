import Foundation
import SwiftData

@Model
final class SpinResult {
    var id: UUID
    var categoryRawValue: String
    var spinMode: String
    var timestamp: Date

    var category: FoodCategory? {
        FoodCategory(rawValue: categoryRawValue)
    }

    init(category: FoodCategory, spinMode: SpinMode) {
        self.id = UUID()
        self.categoryRawValue = category.rawValue
        self.spinMode = spinMode.rawValue
        self.timestamp = Date()
    }
}
