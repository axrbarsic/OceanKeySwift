import CoreGraphics
import Foundation

struct MatrixRainConfiguration: Equatable, Sendable {
    var speed: Double
    var glow: Double
    var density: Double
    var glyphSource: MatrixRainGlyphSource
    var palette: MatrixRainPalette
    var seed: Int?

    init(
        speed: Double = 1,
        glow: Double = 0.7,
        density: Double = 0.8,
        glyphSource: MatrixRainGlyphSource = .matrix,
        palette: MatrixRainPalette = .greenTerminal,
        seed: Int? = nil
    ) {
        self.speed = speed
        self.glow = glow
        self.density = density
        self.glyphSource = glyphSource
        self.palette = palette
        self.seed = seed
    }

    static let `default` = MatrixRainConfiguration()

    static func aiPreset(_ preset: AIVisualPreset) -> MatrixRainConfiguration {
        MatrixRainConfiguration(payload: preset.payload)
    }

    init(payload: AIVisualPresetPayload) {
        self.init(
            speed: payload.speed,
            glow: payload.glow,
            density: payload.density,
            glyphSource: MatrixRainGlyphSource(rawValue: payload.glyphSource) ?? .matrix,
            palette: MatrixRainPalette(rawValue: payload.palette) ?? .greenTerminal,
            seed: payload.seed
        )
    }

    var normalizedSpeed: CGFloat {
        CGFloat(min(max(speed, 0.08), 3.0))
    }

    var normalizedGlow: CGFloat {
        CGFloat(min(max(glow, 0), 1))
    }

    var normalizedDensity: CGFloat {
        CGFloat(min(max(density, 0), 1))
    }
}

enum MatrixRainGlyphSource: String, Equatable, Sendable {
    case matrix
    case swiftCode = "swift_code"
    case hotelOps = "hotel_ops"
    case symbols
    case none

    var glyphs: [Character] {
        switch self {
        case .matrix:
            Array(
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" +
                "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃ" +
                "日田大木本山川空海風火水金土月星"
            )
        case .swiftCode:
            Array("SWIFTUIOBSERVATIONASYNCAVFOUNDATIONCLOUDKIT0123456789{}[]().:/")
        case .hotelOps:
            Array("ROOMCARTVIPSLBDONENOTESWASHINGTONTOWELLINEN0123456789")
        case .symbols:
            Array("◆◇●○▲△▰▱▣▢✦✧✚✖︎0123456789")
        case .none:
            Array("0123456789")
        }
    }
}

enum MatrixRainPalette: String, Equatable, Sendable {
    case greenTerminal = "green_terminal"
    case statusAdaptive = "status_adaptive"
    case emeraldCode = "emerald_code"
    case acidDebug = "acid_debug"

    var background: CGColorComponents {
        switch self {
        case .greenTerminal:
            CGColorComponents(red: 2 / 255, green: 8 / 255, blue: 4 / 255)
        case .statusAdaptive:
            CGColorComponents(red: 5 / 255, green: 6 / 255, blue: 9 / 255)
        case .emeraldCode:
            CGColorComponents(red: 0 / 255, green: 12 / 255, blue: 8 / 255)
        case .acidDebug:
            CGColorComponents(red: 9 / 255, green: 5 / 255, blue: 12 / 255)
        }
    }

    var glyph: CGColorComponents {
        switch self {
        case .greenTerminal:
            CGColorComponents(red: 130 / 255, green: 1, blue: 100 / 255)
        case .statusAdaptive:
            CGColorComponents(red: 0.85, green: 0.95, blue: 1)
        case .emeraldCode:
            CGColorComponents(red: 70 / 255, green: 1, blue: 170 / 255)
        case .acidDebug:
            CGColorComponents(red: 0.78, green: 1, blue: 0.12)
        }
    }
}

struct CGColorComponents: Equatable, Sendable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
}
