import SwiftUI

enum FoodCategory: String, CaseIterable, Codable, Identifiable {
    case pizza, sushi, mexican, burgers, ramen
    case bbq, indian, italian, seafood, korean
    case thai, mediterranean

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pizza:         return "Pizza"
        case .sushi:         return "Sushi"
        case .mexican:       return "Mexican"
        case .burgers:       return "Burgers"
        case .ramen:         return "Ramen"
        case .bbq:           return "BBQ"
        case .indian:        return "Indian"
        case .italian:       return "Italian"
        case .seafood:       return "Seafood"
        case .korean:        return "Korean"
        case .thai:          return "Thai"
        case .mediterranean: return "Mediterranean"
        }
    }

    var emoji: String {
        switch self {
        case .pizza:         return "🍕"
        case .sushi:         return "🍣"
        case .mexican:       return "🌮"
        case .burgers:       return "🍔"
        case .ramen:         return "🍜"
        case .bbq:           return "🍖"
        case .indian:        return "🍛"
        case .italian:       return "🍝"
        case .seafood:       return "🦞"
        case .korean:        return "🥩"
        case .thai:          return "🌶️"
        case .mediterranean: return "🥙"
        }
    }

    var searchTerm: String {
        switch self {
        case .pizza:         return "pizza restaurant"
        case .sushi:         return "sushi restaurant"
        case .mexican:       return "Mexican restaurant"
        case .burgers:       return "burger restaurant"
        case .ramen:         return "ramen restaurant"
        case .bbq:           return "BBQ restaurant"
        case .indian:        return "Indian restaurant"
        case .italian:       return "Italian restaurant"
        case .seafood:       return "seafood restaurant"
        case .korean:        return "Korean restaurant"
        case .thai:          return "Thai restaurant"
        case .mediterranean: return "Mediterranean restaurant"
        }
    }

    // Soft pastel palette from the Picky Eater design system.
    // Low-chroma, warm tones so all 12 slices read as the same
    // visual family on the wheel — no single slice dominates.
    var color: Color {
        switch self {
        case .pizza:         return .wedgePizza
        case .sushi:         return .wedgeSushi
        case .mexican:       return .wedgeMexican
        case .burgers:       return .wedgeBurgers
        case .ramen:         return .wedgeRamen
        case .bbq:           return .wedgeBBQ
        case .indian:        return .wedgeIndian
        case .italian:       return .wedgeItalian
        case .seafood:       return .wedgeSeafood
        case .korean:        return .wedgeKorean
        case .thai:          return .wedgeThai
        case .mediterranean: return .wedgeMediterranean
        }
    }
}

extension FoodCategory {
    /// The category under the top pointer after the wheel has rotated `rotationDegrees`.
    /// Wedge i is drawn spanning [sliceAngle*i - 90, sliceAngle*(i+1) - 90); the pointer sits at 12 o'clock.
    static func category(forRotation rotationDegrees: Double) -> FoodCategory {
        let count = allCases.count
        let slice = 360.0 / Double(count)
        let normalized = (rotationDegrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let adjusted = ((360 - normalized).truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        let index = Int(adjusted / slice) % count
        return allCases[index]
    }
}
