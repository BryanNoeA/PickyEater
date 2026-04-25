import SwiftUI

enum FoodCategory: String, CaseIterable, Codable, Identifiable {
    case italian
    case mexican
    case sushi
    case chinese
    case american
    case thai
    case indian
    case mediterranean
    case burgers
    case pizza
    case sandwiches
    case salads
    case korean
    case vietnamese
    case greek
    case bbq
    case seafood
    case breakfast
    case ramen
    case tacos

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .italian: return "Italian"
        case .mexican: return "Mexican"
        case .sushi: return "Sushi"
        case .chinese: return "Chinese"
        case .american: return "American"
        case .thai: return "Thai"
        case .indian: return "Indian"
        case .mediterranean: return "Mediterranean"
        case .burgers: return "Burgers"
        case .pizza: return "Pizza"
        case .sandwiches: return "Sandwiches"
        case .salads: return "Salads"
        case .korean: return "Korean"
        case .vietnamese: return "Vietnamese"
        case .greek: return "Greek"
        case .bbq: return "BBQ"
        case .seafood: return "Seafood"
        case .breakfast: return "Breakfast"
        case .ramen: return "Ramen"
        case .tacos: return "Tacos"
        }
    }

    var emoji: String {
        switch self {
        case .italian: return "🍝"
        case .mexican: return "🌮"
        case .sushi: return "🍣"
        case .chinese: return "🥡"
        case .american: return "🍔"
        case .thai: return "🍜"
        case .indian: return "🍛"
        case .mediterranean: return "🥙"
        case .burgers: return "🍔"
        case .pizza: return "🍕"
        case .sandwiches: return "🥪"
        case .salads: return "🥗"
        case .korean: return "🫕"
        case .vietnamese: return "🍲"
        case .greek: return "🫒"
        case .bbq: return "🍖"
        case .seafood: return "🦞"
        case .breakfast: return "🍳"
        case .ramen: return "🍜"
        case .tacos: return "🌮"
        }
    }

    var searchTerm: String {
        switch self {
        case .italian: return "Italian restaurant"
        case .mexican: return "Mexican restaurant"
        case .sushi: return "sushi restaurant"
        case .chinese: return "Chinese restaurant"
        case .american: return "American restaurant"
        case .thai: return "Thai restaurant"
        case .indian: return "Indian restaurant"
        case .mediterranean: return "Mediterranean restaurant"
        case .burgers: return "burger restaurant"
        case .pizza: return "pizza restaurant"
        case .sandwiches: return "sandwich shop"
        case .salads: return "salad restaurant"
        case .korean: return "Korean restaurant"
        case .vietnamese: return "Vietnamese restaurant"
        case .greek: return "Greek restaurant"
        case .bbq: return "BBQ restaurant"
        case .seafood: return "seafood restaurant"
        case .breakfast: return "breakfast restaurant"
        case .ramen: return "ramen restaurant"
        case .tacos: return "taco restaurant"
        }
    }

    var color: Color {
        switch self {
        case .italian: return Color(red: 0.85, green: 0.20, blue: 0.20)
        case .mexican: return Color(red: 0.95, green: 0.55, blue: 0.10)
        case .sushi: return Color(red: 0.95, green: 0.20, blue: 0.40)
        case .chinese: return Color(red: 0.90, green: 0.10, blue: 0.10)
        case .american: return Color(red: 0.20, green: 0.40, blue: 0.80)
        case .thai: return Color(red: 0.90, green: 0.70, blue: 0.10)
        case .indian: return Color(red: 0.95, green: 0.45, blue: 0.05)
        case .mediterranean: return Color(red: 0.10, green: 0.65, blue: 0.80)
        case .burgers: return Color(red: 0.70, green: 0.40, blue: 0.10)
        case .pizza: return Color(red: 0.95, green: 0.30, blue: 0.10)
        case .sandwiches: return Color(red: 0.55, green: 0.80, blue: 0.30)
        case .salads: return Color(red: 0.20, green: 0.75, blue: 0.25)
        case .korean: return Color(red: 0.80, green: 0.15, blue: 0.30)
        case .vietnamese: return Color(red: 0.40, green: 0.75, blue: 0.45)
        case .greek: return Color(red: 0.20, green: 0.45, blue: 0.85)
        case .bbq: return Color(red: 0.60, green: 0.20, blue: 0.05)
        case .seafood: return Color(red: 0.10, green: 0.55, blue: 0.85)
        case .breakfast: return Color(red: 0.95, green: 0.80, blue: 0.20)
        case .ramen: return Color(red: 0.75, green: 0.25, blue: 0.55)
        case .tacos: return Color(red: 0.95, green: 0.60, blue: 0.15)
        }
    }
}
