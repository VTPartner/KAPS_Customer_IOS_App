import SwiftUI

struct Colors {
    static let primary = Color(hex: "2A62FF")
    static let primaryDark = Color(hex: "2A62FF")
    static let primaryClick = Color(hex: "233BC8")
    static let accent = Color(hex: "2A62FF")
    static let white = Color(hex: "FFFFFF")
    static let black = Color(hex: "171A29")
    static let black1 = Color(hex: "404040")
    static let grey0 = Color(hex: "F9F9F9")
    static let grey1 = Color(hex: "F4F3F3")
    static let grey = Color(hex: "CFCFCF")
    static let grey2 = Color(hex: "B3B3B3")
    static let grey3 = Color(hex: "7A7878")
    static let green = Color(hex: "61B047")
    static let error = Color(hex: "FF5657")
    static let background = Color(hex: "F6F5FA")
    
    // Status Colors
    static let blue = Color(hex: "2196F3")
    static let orange = Color(hex: "FF9800")
    static let indigo = Color(hex: "3F51B5")
    static let statusGreen = Color(hex: "4CAF50")
    static let statusGrey = Color(hex: "9E9E9E")
    static let shimmer = Color(hex: "DDDDDD")
    static let outstation = Color(hex: "E64A19")
    static let local = Color(hex: "2E7D32")
    static let lightBlue = Color(hex: "E3F2FD")
    static let lightGray = Color(hex: "F5F5F5")
    static let divider = Color(hex: "E0E0E0")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 