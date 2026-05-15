import SwiftUI

/// Central repository for app-wide design tokens: colors and corner radii.
enum AppTheme {
    // MARK: - Colours

    /// Primary brand accent color.
    static let brandPink     = Color(hex: "E8446A")
    /// Tinted background used behind pink UI elements.
    static let brandPinkLight = Color(hex: "FDEEF2")
    /// Pressed/active state for brand-pink interactive elements.
    static let brandPinkDark  = Color(hex: "C02D53")
    /// Primary text and icon color.
    static let charcoal      = Color(hex: "1A1A2E")
    /// Default page background color.
    static let warmGray      = Color(hex: "F7F4F2")
    /// Secondary and placeholder text color.
    static let mutedGray     = Color(hex: "8E8E9A")

    // MARK: - Radii

    /// Corner radius for card containers.
    static let cardRadius:   CGFloat = 16
    /// Corner radius for filter chips and tags.
    static let chipRadius:   CGFloat = 20
    /// Corner radius for primary action buttons.
    static let buttonRadius: CGFloat = 14
}

/// Exposes `AppTheme` palette tokens as `Color` static members for ergonomic use in SwiftUI.
extension Color {
    // MARK: - Convenience
    static let brandPink      = AppTheme.brandPink
    static let brandPinkLight = AppTheme.brandPinkLight
    static let brandPinkDark  = AppTheme.brandPinkDark
    static let charcoal       = AppTheme.charcoal
    static let warmGray       = AppTheme.warmGray
    static let mutedGray      = AppTheme.mutedGray

    // MARK: - Hex init

    /// Creates a `Color` from a CSS-style hex string in `#RGB`, `#RRGGBB`, or `#RRGGBBAA` format.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        // Supported formats: #RGB, #RRGGBB, #RRGGBBAA
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int & 0xFF, int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF) // RRGGBBAA
        default:
            assertionFailure("AppTheme: invalid hex string '\(hex)'")
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
