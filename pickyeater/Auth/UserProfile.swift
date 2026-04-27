import Foundation

/// One row in the Supabase `profiles` table.
/// The `id` matches `auth.users.id` — a Supabase trigger auto-creates this row
/// the moment a user signs up through any provider (Apple, Google, or email).
struct UserProfile: Codable, Sendable {
    let id: UUID

    /// Whether this account has purchased Picky Eater Premium.
    /// This is the source of truth — StoreKit is used to complete the purchase,
    /// but this flag is what unlocks features across all the user's devices.
    var isPremium: Bool

    /// When premium was granted. Used for support and analytics.
    var premiumPurchasedAt: Date?

    /// Apple's stable, device-independent user identifier.
    /// Stored on first Apple sign-in so we can detect and prevent duplicate
    /// accounts if someone tries to sign up with Apple again later.
    var appleUserIdentifier: String?

    /// JSONB blob for user preferences. Intentionally flexible so V2 AI mode
    /// can store dietary restrictions, mood defaults, etc. without schema changes.
    var preferences: UserPreferences?

    // Match the snake_case column names in Supabase
    enum CodingKeys: String, CodingKey {
        case id
        case isPremium           = "is_premium"
        case premiumPurchasedAt  = "premium_purchased_at"
        case appleUserIdentifier = "apple_user_identifier"
        case preferences
    }
}

/// Expandable preferences bag. Add fields here as V2 features ship.
/// Stored as JSONB in Supabase so no migration is needed to add new keys.
struct UserPreferences: Codable, Sendable {
    // V2 AI mode will add: dietaryRestrictions, defaultMood, defaultBudget, etc.
}

// MARK: - Encodable helpers for Supabase writes

/// Payload for creating a new profile row.
struct NewProfile: Encodable, Sendable {
    let id: UUID
    let isPremium: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case isPremium = "is_premium"
    }
}

/// Payload for updating the premium flag.
struct PremiumUpdate: Encodable, Sendable {
    let isPremium: Bool

    enum CodingKeys: String, CodingKey {
        case isPremium = "is_premium"
    }
}

/// Payload for storing an Apple user identifier on the profile.
struct AppleIdentifierUpdate: Encodable, Sendable {
    let id: UUID
    let appleUserIdentifier: String

    enum CodingKeys: String, CodingKey {
        case id
        case appleUserIdentifier = "apple_user_identifier"
    }
}
