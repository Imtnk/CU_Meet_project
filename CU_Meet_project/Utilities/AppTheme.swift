import SwiftUI
import UIKit

// MARK: - UIColor helpers for dynamic (light/dark) colors

extension UIColor {
    /// Creates a `UIColor` from a CSS-style hex string (`#RGB`, `#RRGGBB`, or `#RRGGBBAA`).
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int & 0xFF, int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF)
        default: (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }

    /// Returns a dynamic color that switches between light and dark hex values based on the trait collection.
    static func dynamicColor(lightHex: String, darkHex: String) -> UIColor {
        UIColor { traitCollection in
            let hex = traitCollection.userInterfaceStyle == .dark ? darkHex : lightHex
            return UIColor(hex: hex)
        }
    }
}

/// Central repository for app-wide design tokens: colors and corner radii.
enum AppTheme {
    // MARK: - Colours

    /// Primary brand accent color.
    static var brandPink: Color {
        Color(uiColor: .dynamicColor(lightHex: "E8446A", darkHex: "FF6B8A"))
    }
    /// Tinted background used behind pink UI elements.
    static var brandPinkLight: Color {
        Color(uiColor: .dynamicColor(lightHex: "FDEEF2", darkHex: "3D1A24"))
    }
    /// Pressed/active state for brand-pink interactive elements.
    static var brandPinkDark: Color {
        Color(uiColor: .dynamicColor(lightHex: "C02D53", darkHex: "E8557A"))
    }
    /// Primary text and icon color.
    static var charcoal: Color {
        Color(uiColor: .dynamicColor(lightHex: "1A1A2E", darkHex: "F0F0F5"))
    }
    /// Default page background color.
    static var warmGray: Color {
        Color(uiColor: .dynamicColor(lightHex: "F7F4F2", darkHex: "1C1C1E"))
    }
    /// Secondary and placeholder text color.
    static var mutedGray: Color {
        Color(uiColor: .dynamicColor(lightHex: "8E8E9A", darkHex: "AEAEB2"))
    }
    /// Card container background.
    static var cardBackground: Color {
        Color(uiColor: .dynamicColor(lightHex: "FFFFFF", darkHex: "2C2C2E"))
    }

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
    static let cardBackground = AppTheme.cardBackground

    // MARK: - Hex init

    /// Creates a `Color` from a CSS-style hex string in `#RGB`, `#RRGGBB`, or `#RRGGBBAA` format.
    init(hex: String) {
        self = Color(uiColor: UIColor(hex: hex))
    }
}
