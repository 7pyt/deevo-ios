import SwiftUI

// Reprend telles quelles les variables CSS de src/style.css (version
// desktop) pour que l'app iOS ait la même identité visuelle : fond très
// sombre, accent orange chaud, cartes en "verre dépoli".
enum DeevoTheme {
    static let bgVoid = Color(hex: 0x0b0b0c)
    static let bgPanel = Color(hex: 0x121213)
    static let bgPanel2 = Color(hex: 0x19191b)
    static let bgElevated = Color(hex: 0x212123)

    static let line = Color(hex: 0x2a2a2c)
    static let lineSoft = Color(hex: 0x1e1e20)

    static let textPrimary = Color(hex: 0xf2f0ec)
    static let textDim = Color(hex: 0x9a968f)
    static let textFaint = Color(hex: 0x5c5a56)

    static let accent = Color(hex: 0xc77b3f)
    static let accentBright = Color(hex: 0xe2955a)
    static let accentDim = Color(hex: 0xc77b3f).opacity(0.16)

    static let radiusXS: CGFloat = 8
    static let radiusS: CGFloat = 10
    static let radiusM: CGFloat = 16
    static let radiusL: CGFloat = 24
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: opacity
        )
    }
}

// "Verre dépoli" façon --glass-bg / --glass-border du CSS desktop : à poser
// sur un fond déjà sombre (bgPanel/bgPanel2), jamais seul sur du blanc.
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = DeevoTheme.radiusM

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.045))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
            )
    }
}

extension View {
    func deevoGlass(cornerRadius: CGFloat = DeevoTheme.radiusM) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}
