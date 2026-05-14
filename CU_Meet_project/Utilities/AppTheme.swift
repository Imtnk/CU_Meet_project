import SwiftUI

enum AppTheme {
    // MARK: - Colours
    static let brandPink     = Color(hex: "E8446A")
    static let brandPinkLight = Color(hex: "FDEEF2")
    static let brandPinkDark  = Color(hex: "C02D53")
    static let charcoal      = Color(hex: "1A1A2E")
    static let warmGray      = Color(hex: "F7F4F2")
    static let mutedGray     = Color(hex: "8E8E9A")

    // MARK: - Radii
    static let cardRadius:   CGFloat = 16
    static let chipRadius:   CGFloat = 20
    static let buttonRadius: CGFloat = 14
}

extension Color {
    // MARK: - Convenience
    static let brandPink      = AppTheme.brandPink
    static let brandPinkLight = AppTheme.brandPinkLight
    static let brandPinkDark  = AppTheme.brandPinkDark
    static let charcoal       = AppTheme.charcoal
    static let warmGray       = AppTheme.warmGray
    static let mutedGray      = AppTheme.mutedGray

    // MARK: - Hex init
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
