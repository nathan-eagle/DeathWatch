import SwiftUI

extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&value)
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}

struct Accent: Identifiable, Hashable {
    let id: String
    let name: String
    let solid: Color
    let gradientStart: Color
    let gradientEnd: Color

    init(id: String, name: String, solid: String, gradientStart: String, gradientEnd: String) {
        self.id = id
        self.name = name
        self.solid = Color(hex: solid)
        self.gradientStart = Color(hex: gradientStart)
        self.gradientEnd = Color(hex: gradientEnd)
    }

    var linearGradient: LinearGradient {
        LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var barGradient: LinearGradient {
        LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .leading, endPoint: .trailing)
    }

    var angularGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [gradientStart, gradientEnd]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }

    var track: Color { solid.opacity(DW.trackOpacity) }

    static let presets: [Accent] = [
        Accent(id: "coral", name: "Coral", solid: "#FF6159", gradientStart: "#FF8A7A", gradientEnd: "#F43F5E"),
        Accent(id: "tangerine", name: "Tangerine", solid: "#FF8A00", gradientStart: "#FFB340", gradientEnd: "#FF6B00"),
        Accent(id: "honey", name: "Honey", solid: "#FFC233", gradientStart: "#FFD966", gradientEnd: "#FFA51F"),
        Accent(id: "meadow", name: "Meadow", solid: "#30C463", gradientStart: "#6EE7A0", gradientEnd: "#18A957"),
        Accent(id: "teal", name: "Teal", solid: "#14B8A6", gradientStart: "#3DDAC4", gradientEnd: "#0E9488"),
        Accent(id: "sky", name: "Sky", solid: "#38B6FF", gradientStart: "#7CD4FF", gradientEnd: "#1E8FFF"),
        Accent(id: "cobalt", name: "Cobalt", solid: "#3A66F5", gradientStart: "#5B8CFF", gradientEnd: "#2B4DE0"),
        Accent(id: "iris", name: "Iris", solid: "#6C5CE7", gradientStart: "#9B8CFF", gradientEnd: "#5A3FD6"),
        Accent(id: "orchid", name: "Orchid", solid: "#A855F7", gradientStart: "#C084FC", gradientEnd: "#8B2FD6"),
        Accent(id: "rose", name: "Rose", solid: "#F04E98", gradientStart: "#FF7AB8", gradientEnd: "#DB2777"),
        Accent(id: "sand", name: "Sand", solid: "#C7A06B", gradientStart: "#DBB98A", gradientEnd: "#A87E4A"),
        Accent(id: "graphite", name: "Graphite", solid: "#3A3A41", gradientStart: "#5A5A64", gradientEnd: "#232328")
    ]

    static let coral = presets[0]

    static func preset(id: String) -> Accent {
        presets.first { $0.id == id } ?? coral
    }
}

final class AccentStore: ObservableObject {
    @Published private(set) var accent: Accent

    init() {
        accent = Accent.preset(id: LifeEngine.accentID)
    }

    func select(_ accent: Accent) {
        self.accent = accent
        LifeEngine.accentID = accent.id
    }

    static var current: Accent { Accent.preset(id: LifeEngine.accentID) }
}

enum DW {
    // MARK: - Typography

    static func numberFont(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func heroFont(_ size: CGFloat) -> Font {
        numberFont(size, weight: .heavy)
    }

    static func percentFont(_ size: CGFloat = 15) -> Font {
        numberFont(size, weight: .semibold)
    }

    static let unitLabelFont = Font.system(size: 11, weight: .medium)
    static let unitLabelTracking: CGFloat = 1.2

    static func unitLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(unitLabelFont)
            .tracking(unitLabelTracking)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .allowsTightening(true)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
    }

    // MARK: - Metrics

    static let trackOpacity: Double = 0.26
    static let emptyDotOpacity: Double = 0.85
    static let dotGapRatio: CGFloat = 0.32
    static let currentDotCoreScale: CGFloat = 0.5
    static let ringLineWidthRatio: CGFloat = 0.12
}
