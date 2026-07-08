import SwiftUI
import UIKit

/// Brand color tokens for Picky Eater.
///
/// Usage: `Color.appBackground`, `Color.persimmon`, etc.
/// The accent color is set globally via AccentColor.colorset — use
/// `.accentColor` or `Color.accentColor` rather than `.persimmon`
/// for interactive controls (buttons, toggles) so iOS tinting works correctly.
extension Color {

    // MARK: - Surfaces

    /// Warm off-white background — #FCF9F4 light / #13110F dark.
    /// Set in Assets.xcassets so dark mode is handled automatically.
    /// Named `peBackground` to avoid clashing with iOS 26's system `appBackground`.
    static let peBackground = Color("AppBackground")

    // MARK: - Brand

    /// Persimmon 500 — #FF5A1F. Primary brand accent (light mode).
    /// Prefer `.accentColor` for tinted controls; use this for
    /// custom-drawn elements like the wheel pointer or custom buttons.
    static let persimmon     = Color(red: 1.0,   green: 0.353, blue: 0.122)

    /// Persimmon 100 — #FFE3D2. Soft persimmon used for active toggle pills.
    static let persimmonSoft = Color(red: 1.0,   green: 0.890, blue: 0.824)

    /// Persimmon 700 — #B8350D. Dark foreground on persimmon-soft backgrounds.
    static let persimmonDark = Color(red: 0.722, green: 0.208, blue: 0.051)

    // MARK: - Adaptive text

    /// Primary title text — dark warm brown (light) / warm off-white (dark).
    static let peTextPrimary = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1)
        : UIColor(red: 0.102, green: 0.078, blue: 0.063, alpha: 1)
    })

    /// Secondary/subtitle text — muted warm gray, adapts for dark mode contrast.
    static let peTextSecondary = Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(red: 0.70, green: 0.66, blue: 0.60, alpha: 1)
        : UIColor(red: 0.420, green: 0.361, blue: 0.322, alpha: 1)
    })

    // MARK: - Wheel wedge palette (12 soft pastels, design system)
    // Mapped in the same order as FoodCategory.allCases.

    static let wedgePizza         = Color(red: 1.000, green: 0.902, blue: 0.659) // butter yellow  #FFE6A8
    static let wedgeSushi         = Color(red: 0.910, green: 0.878, blue: 0.941) // lavender       #E8E0F0
    static let wedgeMexican       = Color(red: 1.000, green: 0.847, blue: 0.722) // warm peach     #FFD8B8
    static let wedgeBurgers       = Color(red: 1.000, green: 0.902, blue: 0.800) // light peach    #FFE6CC
    static let wedgeRamen         = Color(red: 0.894, green: 0.918, blue: 0.847) // sage           #E4EAD8
    static let wedgeBBQ           = Color(red: 1.000, green: 0.847, blue: 0.784) // salmon peach   #FFD8C8
    static let wedgeIndian        = Color(red: 1.000, green: 0.878, blue: 0.722) // amber peach    #FFE0B8
    static let wedgeItalian       = Color(red: 1.000, green: 0.878, blue: 0.863) // blush          #FFE0DC
    static let wedgeSeafood       = Color(red: 0.863, green: 0.878, blue: 0.925) // pale blue      #DCE0EC
    static let wedgeKorean        = Color(red: 0.941, green: 0.863, blue: 0.816) // dusty rose     #F0DCD0
    static let wedgeThai          = Color(red: 0.910, green: 0.863, blue: 0.918) // lilac          #E8DCEA
    static let wedgeMediterranean = Color(red: 0.878, green: 0.910, blue: 0.863) // pale sage      #E0E8DC
}
