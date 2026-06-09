import Foundation
import Observation

enum AppBackgroundMode: String, CaseIterable, Identifiable, Codable {
    case off
    case matrixRain
    case tvStaticNoise
    case video

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off:
            "Выкл"
        case .matrixRain:
            "Matrix"
        case .tvStaticNoise:
            "TV"
        case .video:
            "Видео"
        }
    }

    var description: String {
        switch self {
        case .off:
            "Чёрный фон"
        case .matrixRain:
            "Matrix Rain"
        case .tvStaticNoise:
            "Сломанный телевизор"
        case .video:
            "Видео фон"
        }
    }
}

@Observable
final class AppSettingsStore {
    private enum Keys {
        static let appBackgroundMode = "appBackgroundMode"
        static let roomCellGeometry = "roomCellGeometry"
        static let roomTaskLongPress = "roomTaskLongPress"
        static let summaryActionMenuAllowsMultiple = "summaryActionMenuAllowsMultiple"
        static let statusPaletteSaturation = "statusPaletteSaturation"
        static let matrixSpeed = "matrixSpeed"
        static let backgroundVideoRelativePath = "backgroundVideoRelativePath"
        static let backgroundVideoBlur = "backgroundVideoBlur"
        static let backgroundVideoBrightness = "backgroundVideoBrightness"
        static let backgroundVideoGreenTint = "backgroundVideoGreenTint"
        static let backgroundVideoGridIntensity = "backgroundVideoGridIntensity"
        static let tvStaticSpeed = "tvStaticSpeed"
        static let tvStaticParticleSize = "tvStaticParticleSize"
        static let tvStaticBrightness = "tvStaticBrightness"
        static let tvStaticGreenTint = "tvStaticGreenTint"
        static let developerCellPhysicsEnabled = "developerCellPhysicsEnabled"
        static let developerCellSpringIntensity = "developerCellSpringIntensity"
        static let developerCellSpringSpeed = "developerCellSpringSpeed"
        static let developerVIPZebraIntensity = "developerVIPZebraIntensity"
        static let developerVIPZebraSpeed = "developerVIPZebraSpeed"
        static let developerVIPZebraSharpness = "developerVIPZebraSharpness"
        static let developerCellTVStaticEnabled = "developerCellTVStaticEnabled"
        static let developerVIPFlickerEnabled = "developerVIPFlickerEnabled"
        static let developerVIPFlickerSpeed = "developerVIPFlickerSpeed"
        static let developerVIPBreathingEnabled = "developerVIPBreathingEnabled"
        static let developerVIPBreathingSpeed = "developerVIPBreathingSpeed"
    }

    @ObservationIgnored private let userDefaults: UserDefaults
    private var storedStatusPaletteSaturation: Double
    private var storedMatrixSpeed: Double
    private var storedBackgroundVideoBlur: Double
    private var storedBackgroundVideoBrightness: Double
    private var storedBackgroundVideoGreenTint: Double
    private var storedBackgroundVideoGridIntensity: Double
    private var storedTVStaticSpeed: Double
    private var storedTVStaticParticleSize: Double
    private var storedTVStaticBrightness: Double
    private var storedTVStaticGreenTint: Double
    private var storedDeveloperCellSpringIntensity: Double
    private var storedDeveloperCellSpringSpeed: Double
    private var storedDeveloperVIPZebraIntensity: Double
    private var storedDeveloperVIPZebraSpeed: Double
    private var storedDeveloperVIPZebraSharpness: Double
    private var storedDeveloperVIPFlickerSpeed: Double
    private var storedDeveloperVIPBreathingSpeed: Double

    var appBackgroundMode: AppBackgroundMode {
        didSet {
            userDefaults.set(appBackgroundMode.rawValue, forKey: Keys.appBackgroundMode)
        }
    }

    var roomCellGeometry: RoomCellGeometry {
        didSet {
            userDefaults.set(roomCellGeometry.rawValue, forKey: Keys.roomCellGeometry)
        }
    }

    var roomTaskLongPress: Bool {
        didSet {
            userDefaults.set(roomTaskLongPress, forKey: Keys.roomTaskLongPress)
        }
    }

    var summaryActionMenuAllowsMultiple: Bool {
        didSet {
            userDefaults.set(summaryActionMenuAllowsMultiple, forKey: Keys.summaryActionMenuAllowsMultiple)
        }
    }

    var statusPaletteSaturation: Double {
        get { storedStatusPaletteSaturation }
        set {
            storedStatusPaletteSaturation = Self.normalizedStatusPaletteSaturation(newValue)
            userDefaults.set(storedStatusPaletteSaturation, forKey: Keys.statusPaletteSaturation)
        }
    }

    var vividStatusPaletteEnabled: Bool {
        get { storedStatusPaletteSaturation >= 1.5 }
        set {
            statusPaletteSaturation = newValue ? 1.65 : 1
        }
    }

    var matrixSpeed: Double {
        get { storedMatrixSpeed }
        set {
            storedMatrixSpeed = Self.normalizedMatrixSpeed(newValue)
            userDefaults.set(storedMatrixSpeed, forKey: Keys.matrixSpeed)
        }
    }

    var backgroundVideoRelativePath: String? {
        didSet {
            userDefaults.set(backgroundVideoRelativePath, forKey: Keys.backgroundVideoRelativePath)
        }
    }

    var backgroundVideoBlur: Double {
        get { storedBackgroundVideoBlur }
        set {
            storedBackgroundVideoBlur = Self.normalizedBackgroundVideoBlur(newValue)
            userDefaults.set(storedBackgroundVideoBlur, forKey: Keys.backgroundVideoBlur)
        }
    }

    var backgroundVideoBrightness: Double {
        get { storedBackgroundVideoBrightness }
        set {
            storedBackgroundVideoBrightness = Self.normalizedBackgroundVideoBrightness(newValue)
            userDefaults.set(storedBackgroundVideoBrightness, forKey: Keys.backgroundVideoBrightness)
        }
    }

    var backgroundVideoGreenTint: Double {
        get { storedBackgroundVideoGreenTint }
        set {
            storedBackgroundVideoGreenTint = Self.normalizedBackgroundVideoGreenTint(newValue)
            userDefaults.set(storedBackgroundVideoGreenTint, forKey: Keys.backgroundVideoGreenTint)
        }
    }

    var backgroundVideoGridIntensity: Double {
        get { storedBackgroundVideoGridIntensity }
        set {
            storedBackgroundVideoGridIntensity = Self.normalizedBackgroundVideoGridIntensity(newValue)
            userDefaults.set(storedBackgroundVideoGridIntensity, forKey: Keys.backgroundVideoGridIntensity)
        }
    }

    var tvStaticSpeed: Double {
        get { storedTVStaticSpeed }
        set {
            storedTVStaticSpeed = Self.normalizedTVStaticSpeed(newValue)
            userDefaults.set(storedTVStaticSpeed, forKey: Keys.tvStaticSpeed)
        }
    }

    var tvStaticParticleSize: Double {
        get { storedTVStaticParticleSize }
        set {
            storedTVStaticParticleSize = Self.normalizedTVStaticParticleSize(newValue)
            userDefaults.set(storedTVStaticParticleSize, forKey: Keys.tvStaticParticleSize)
        }
    }

    var tvStaticBrightness: Double {
        get { storedTVStaticBrightness }
        set {
            storedTVStaticBrightness = Self.normalizedTVStaticBrightness(newValue)
            userDefaults.set(storedTVStaticBrightness, forKey: Keys.tvStaticBrightness)
        }
    }

    var tvStaticGreenTint: Double {
        get { storedTVStaticGreenTint }
        set {
            storedTVStaticGreenTint = Self.normalizedTVStaticGreenTint(newValue)
            userDefaults.set(storedTVStaticGreenTint, forKey: Keys.tvStaticGreenTint)
        }
    }

    var developerCellPhysicsEnabled: Bool {
        didSet {
            userDefaults.set(developerCellPhysicsEnabled, forKey: Keys.developerCellPhysicsEnabled)
        }
    }

    var developerCellTVStaticEnabled: Bool {
        didSet {
            userDefaults.set(developerCellTVStaticEnabled, forKey: Keys.developerCellTVStaticEnabled)
        }
    }

    var developerVIPFlickerEnabled: Bool {
        didSet {
            userDefaults.set(developerVIPFlickerEnabled, forKey: Keys.developerVIPFlickerEnabled)
        }
    }

    var developerVIPBreathingEnabled: Bool {
        didSet {
            userDefaults.set(developerVIPBreathingEnabled, forKey: Keys.developerVIPBreathingEnabled)
        }
    }

    var developerCellSpringIntensity: Double {
        get { storedDeveloperCellSpringIntensity }
        set {
            storedDeveloperCellSpringIntensity = Self.normalizedDeveloperCellSpringIntensity(newValue)
            userDefaults.set(storedDeveloperCellSpringIntensity, forKey: Keys.developerCellSpringIntensity)
        }
    }

    var developerCellSpringSpeed: Double {
        get { storedDeveloperCellSpringSpeed }
        set {
            storedDeveloperCellSpringSpeed = Self.normalizedDeveloperCellSpringSpeed(newValue)
            userDefaults.set(storedDeveloperCellSpringSpeed, forKey: Keys.developerCellSpringSpeed)
        }
    }

    var developerVIPZebraIntensity: Double {
        get { storedDeveloperVIPZebraIntensity }
        set {
            storedDeveloperVIPZebraIntensity = Self.normalizedDeveloperVIPZebraIntensity(newValue)
            userDefaults.set(storedDeveloperVIPZebraIntensity, forKey: Keys.developerVIPZebraIntensity)
        }
    }

    var developerVIPZebraSpeed: Double {
        get { storedDeveloperVIPZebraSpeed }
        set {
            storedDeveloperVIPZebraSpeed = Self.normalizedDeveloperVIPZebraSpeed(newValue)
            userDefaults.set(storedDeveloperVIPZebraSpeed, forKey: Keys.developerVIPZebraSpeed)
        }
    }

    var developerVIPZebraSharpness: Double {
        get { storedDeveloperVIPZebraSharpness }
        set {
            storedDeveloperVIPZebraSharpness = Self.normalizedDeveloperVIPZebraSharpness(newValue)
            userDefaults.set(storedDeveloperVIPZebraSharpness, forKey: Keys.developerVIPZebraSharpness)
        }
    }

    var developerVIPFlickerSpeed: Double {
        get { storedDeveloperVIPFlickerSpeed }
        set {
            storedDeveloperVIPFlickerSpeed = Self.normalizedDeveloperVIPFlickerSpeed(newValue)
            userDefaults.set(storedDeveloperVIPFlickerSpeed, forKey: Keys.developerVIPFlickerSpeed)
        }
    }

    var developerVIPBreathingSpeed: Double {
        get { storedDeveloperVIPBreathingSpeed }
        set {
            storedDeveloperVIPBreathingSpeed = Self.normalizedDeveloperVIPBreathingSpeed(newValue)
            userDefaults.set(storedDeveloperVIPBreathingSpeed, forKey: Keys.developerVIPBreathingSpeed)
        }
    }

    var matrixConfiguration: MatrixRainConfiguration {
        MatrixRainConfiguration(speed: matrixSpeed)
    }

    var tvStaticNoiseConfiguration: TVStaticNoiseConfiguration {
        TVStaticNoiseConfiguration(
            speed: tvStaticSpeed,
            particleSize: tvStaticParticleSize,
            brightness: tvStaticBrightness,
            greenTint: tvStaticGreenTint
        )
    }

    var backgroundVideoURL: URL? {
        guard let backgroundVideoRelativePath else { return nil }
        return BackgroundVideoFileStore().url(for: backgroundVideoRelativePath)
    }

    func resetToDefaults() {
        appBackgroundMode = .matrixRain
        roomCellGeometry = .roomy
        roomTaskLongPress = true
        summaryActionMenuAllowsMultiple = false
        statusPaletteSaturation = 1
        matrixSpeed = MatrixRainConfiguration.default.speed
        backgroundVideoRelativePath = nil
        backgroundVideoBlur = 0.28
        backgroundVideoBrightness = 0.08
        backgroundVideoGreenTint = 0.34
        backgroundVideoGridIntensity = 0
        tvStaticSpeed = TVStaticNoiseConfiguration.default.speed
        tvStaticParticleSize = TVStaticNoiseConfiguration.default.particleSize
        tvStaticBrightness = TVStaticNoiseConfiguration.default.brightness
        tvStaticGreenTint = TVStaticNoiseConfiguration.default.greenTint
        developerCellPhysicsEnabled = false
        developerCellTVStaticEnabled = false
        developerCellSpringIntensity = 0.72
        developerCellSpringSpeed = 0.82
        developerVIPZebraIntensity = 0.86
        developerVIPZebraSpeed = 0.78
        developerVIPZebraSharpness = 0.62
        developerVIPFlickerEnabled = false
        developerVIPFlickerSpeed = 1.6
        developerVIPBreathingEnabled = false
        developerVIPBreathingSpeed = 0.75
    }

    init(
        appBackgroundMode: AppBackgroundMode = .matrixRain,
        roomCellGeometry: RoomCellGeometry = .roomy,
        roomTaskLongPress: Bool = true,
        summaryActionMenuAllowsMultiple: Bool = false,
        statusPaletteSaturation: Double = 1,
        matrixSpeed: Double = MatrixRainConfiguration.default.speed,
        backgroundVideoRelativePath: String? = nil,
        backgroundVideoBlur: Double = 0.28,
        backgroundVideoBrightness: Double = 0.08,
        backgroundVideoGreenTint: Double = 0.34,
        backgroundVideoGridIntensity: Double = 0,
        tvStaticSpeed: Double = TVStaticNoiseConfiguration.default.speed,
        tvStaticParticleSize: Double = TVStaticNoiseConfiguration.default.particleSize,
        tvStaticBrightness: Double = TVStaticNoiseConfiguration.default.brightness,
        tvStaticGreenTint: Double = TVStaticNoiseConfiguration.default.greenTint,
        developerCellPhysicsEnabled: Bool = false,
        developerCellTVStaticEnabled: Bool = false,
        developerCellSpringIntensity: Double = 0.72,
        developerCellSpringSpeed: Double = 0.82,
        developerVIPZebraIntensity: Double = 0.86,
        developerVIPZebraSpeed: Double = 0.78,
        developerVIPZebraSharpness: Double = 0.62,
        developerVIPFlickerEnabled: Bool = false,
        developerVIPFlickerSpeed: Double = 1.6,
        developerVIPBreathingEnabled: Bool = false,
        developerVIPBreathingSpeed: Double = 0.75,
        userDefaults: UserDefaults = .standard
    ) {
        self.appBackgroundMode = appBackgroundMode
        self.roomCellGeometry = roomCellGeometry
        self.roomTaskLongPress = roomTaskLongPress
        self.summaryActionMenuAllowsMultiple = summaryActionMenuAllowsMultiple
        self.backgroundVideoRelativePath = backgroundVideoRelativePath
        self.storedStatusPaletteSaturation = Self.normalizedStatusPaletteSaturation(statusPaletteSaturation)
        self.storedMatrixSpeed = Self.normalizedMatrixSpeed(matrixSpeed)
        self.storedBackgroundVideoBlur = Self.normalizedBackgroundVideoBlur(backgroundVideoBlur)
        self.storedBackgroundVideoBrightness = Self.normalizedBackgroundVideoBrightness(backgroundVideoBrightness)
        self.storedBackgroundVideoGreenTint = Self.normalizedBackgroundVideoGreenTint(backgroundVideoGreenTint)
        self.storedBackgroundVideoGridIntensity = Self.normalizedBackgroundVideoGridIntensity(backgroundVideoGridIntensity)
        self.storedTVStaticSpeed = Self.normalizedTVStaticSpeed(tvStaticSpeed)
        self.storedTVStaticParticleSize = Self.normalizedTVStaticParticleSize(tvStaticParticleSize)
        self.storedTVStaticBrightness = Self.normalizedTVStaticBrightness(tvStaticBrightness)
        self.storedTVStaticGreenTint = Self.normalizedTVStaticGreenTint(tvStaticGreenTint)
        self.storedDeveloperCellSpringIntensity = Self.normalizedDeveloperCellSpringIntensity(developerCellSpringIntensity)
        self.storedDeveloperCellSpringSpeed = Self.normalizedDeveloperCellSpringSpeed(developerCellSpringSpeed)
        self.storedDeveloperVIPZebraIntensity = Self.normalizedDeveloperVIPZebraIntensity(developerVIPZebraIntensity)
        self.storedDeveloperVIPZebraSpeed = Self.normalizedDeveloperVIPZebraSpeed(developerVIPZebraSpeed)
        self.storedDeveloperVIPZebraSharpness = Self.normalizedDeveloperVIPZebraSharpness(developerVIPZebraSharpness)
        self.storedDeveloperVIPFlickerSpeed = Self.normalizedDeveloperVIPFlickerSpeed(developerVIPFlickerSpeed)
        self.storedDeveloperVIPBreathingSpeed = Self.normalizedDeveloperVIPBreathingSpeed(developerVIPBreathingSpeed)
        self.developerCellPhysicsEnabled = developerCellPhysicsEnabled
        self.developerCellTVStaticEnabled = developerCellTVStaticEnabled
        self.developerVIPFlickerEnabled = developerVIPFlickerEnabled
        self.developerVIPBreathingEnabled = developerVIPBreathingEnabled
        self.userDefaults = userDefaults
    }

    static func load(userDefaults: UserDefaults = .standard) -> AppSettingsStore {
        let backgroundRawValue = userDefaults.string(forKey: Keys.appBackgroundMode)
        let appBackgroundMode = backgroundRawValue.flatMap(AppBackgroundMode.init(rawValue:)) ?? .matrixRain
        let rawValue = userDefaults.string(forKey: Keys.roomCellGeometry)
        let geometry = rawValue.flatMap(RoomCellGeometry.init(rawValue:)) ?? .roomy
        let roomTaskLongPress = userDefaults.object(forKey: Keys.roomTaskLongPress) as? Bool ?? true
        let summaryActionMenuAllowsMultiple = userDefaults.object(forKey: Keys.summaryActionMenuAllowsMultiple) as? Bool ?? false
        let statusPaletteSaturation = userDefaults.object(forKey: Keys.statusPaletteSaturation) as? Double ?? 1
        let matrixSpeed = userDefaults.object(forKey: Keys.matrixSpeed) as? Double
            ?? MatrixRainConfiguration.default.speed
        let backgroundVideoRelativePath = userDefaults.string(forKey: Keys.backgroundVideoRelativePath)
        let backgroundVideoBlur = userDefaults.object(forKey: Keys.backgroundVideoBlur) as? Double ?? 0.28
        let backgroundVideoBrightness = userDefaults.object(forKey: Keys.backgroundVideoBrightness) as? Double ?? 0.08
        let backgroundVideoGreenTint = userDefaults.object(forKey: Keys.backgroundVideoGreenTint) as? Double ?? 0.34
        let backgroundVideoGridIntensity = userDefaults.object(forKey: Keys.backgroundVideoGridIntensity) as? Double ?? 0
        let tvStaticSpeed = userDefaults.object(forKey: Keys.tvStaticSpeed) as? Double
            ?? TVStaticNoiseConfiguration.default.speed
        let tvStaticParticleSize = userDefaults.object(forKey: Keys.tvStaticParticleSize) as? Double
            ?? TVStaticNoiseConfiguration.default.particleSize
        let tvStaticBrightness = userDefaults.object(forKey: Keys.tvStaticBrightness) as? Double
            ?? TVStaticNoiseConfiguration.default.brightness
        let tvStaticGreenTint = userDefaults.object(forKey: Keys.tvStaticGreenTint) as? Double
            ?? TVStaticNoiseConfiguration.default.greenTint
        let developerCellPhysicsEnabled = userDefaults.object(forKey: Keys.developerCellPhysicsEnabled) as? Bool ?? false
        let developerCellTVStaticEnabled = userDefaults.object(forKey: Keys.developerCellTVStaticEnabled) as? Bool ?? false
        let developerCellSpringIntensity = userDefaults.object(forKey: Keys.developerCellSpringIntensity) as? Double ?? 0.72
        let developerCellSpringSpeed = userDefaults.object(forKey: Keys.developerCellSpringSpeed) as? Double ?? 0.82
        let developerVIPZebraIntensity = userDefaults.object(forKey: Keys.developerVIPZebraIntensity) as? Double ?? 0.86
        let developerVIPZebraSpeed = userDefaults.object(forKey: Keys.developerVIPZebraSpeed) as? Double ?? 0.78
        let developerVIPZebraSharpness = userDefaults.object(forKey: Keys.developerVIPZebraSharpness) as? Double ?? 0.62
        let developerVIPFlickerEnabled = userDefaults.object(forKey: Keys.developerVIPFlickerEnabled) as? Bool ?? false
        let developerVIPFlickerSpeed = userDefaults.object(forKey: Keys.developerVIPFlickerSpeed) as? Double ?? 1.6
        let developerVIPBreathingEnabled = userDefaults.object(forKey: Keys.developerVIPBreathingEnabled) as? Bool ?? false
        let developerVIPBreathingSpeed = userDefaults.object(forKey: Keys.developerVIPBreathingSpeed) as? Double ?? 0.75
        return AppSettingsStore(
            appBackgroundMode: appBackgroundMode,
            roomCellGeometry: geometry,
            roomTaskLongPress: roomTaskLongPress,
            summaryActionMenuAllowsMultiple: summaryActionMenuAllowsMultiple,
            statusPaletteSaturation: statusPaletteSaturation,
            matrixSpeed: matrixSpeed,
            backgroundVideoRelativePath: backgroundVideoRelativePath,
            backgroundVideoBlur: backgroundVideoBlur,
            backgroundVideoBrightness: backgroundVideoBrightness,
            backgroundVideoGreenTint: backgroundVideoGreenTint,
            backgroundVideoGridIntensity: backgroundVideoGridIntensity,
            tvStaticSpeed: tvStaticSpeed,
            tvStaticParticleSize: tvStaticParticleSize,
            tvStaticBrightness: tvStaticBrightness,
            tvStaticGreenTint: tvStaticGreenTint,
            developerCellPhysicsEnabled: developerCellPhysicsEnabled,
            developerCellTVStaticEnabled: developerCellTVStaticEnabled,
            developerCellSpringIntensity: developerCellSpringIntensity,
            developerCellSpringSpeed: developerCellSpringSpeed,
            developerVIPZebraIntensity: developerVIPZebraIntensity,
            developerVIPZebraSpeed: developerVIPZebraSpeed,
            developerVIPZebraSharpness: developerVIPZebraSharpness,
            developerVIPFlickerEnabled: developerVIPFlickerEnabled,
            developerVIPFlickerSpeed: developerVIPFlickerSpeed,
            developerVIPBreathingEnabled: developerVIPBreathingEnabled,
            developerVIPBreathingSpeed: developerVIPBreathingSpeed,
            userDefaults: userDefaults
        )
    }

    static func normalizedStatusPaletteSaturation(_ value: Double) -> Double {
        min(max(value, 0.70), 1.65)
    }

    static func normalizedMatrixSpeed(_ value: Double) -> Double {
        min(max(value, 0.08), 3.0)
    }

    static func normalizedBackgroundVideoBlur(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func normalizedBackgroundVideoBrightness(_ value: Double) -> Double {
        min(max(value, -0.85), 0.85)
    }

    static func normalizedBackgroundVideoGreenTint(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func normalizedBackgroundVideoGridIntensity(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func normalizedTVStaticSpeed(_ value: Double) -> Double {
        min(max(value, 0.2), 3.0)
    }

    static func normalizedTVStaticParticleSize(_ value: Double) -> Double {
        min(max(value, 0.5), 2.5)
    }

    static func normalizedTVStaticBrightness(_ value: Double) -> Double {
        min(max(value, -0.65), 0.65)
    }

    static func normalizedTVStaticGreenTint(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func normalizedDeveloperCellSpringIntensity(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func normalizedDeveloperCellSpringSpeed(_ value: Double) -> Double {
        min(max(value, 0.2), 1.6)
    }

    static func normalizedDeveloperVIPZebraIntensity(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func normalizedDeveloperVIPZebraSpeed(_ value: Double) -> Double {
        min(max(value, 0.2), 1.8)
    }

    static func normalizedDeveloperVIPZebraSharpness(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    static func normalizedDeveloperVIPFlickerSpeed(_ value: Double) -> Double {
        min(max(value, 0.4), 4.0)
    }

    static func normalizedDeveloperVIPBreathingSpeed(_ value: Double) -> Double {
        min(max(value, 0.2), 2.5)
    }
}
