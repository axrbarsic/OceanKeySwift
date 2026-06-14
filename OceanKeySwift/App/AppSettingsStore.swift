import Foundation
import Observation

enum AppBackgroundMode: String, CaseIterable, Identifiable, Codable {
    case off
    case matrixRain
    case tvStaticNoise
    case video
    case aiGenerated

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
        case .aiGenerated:
            "AI"
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
        case .aiGenerated:
            "AI Wallpaper"
        }
    }
}

enum PersonalCartMarkerInputMode: String, CaseIterable, Identifiable, Codable {
    case swipeDetents
    case pressMenu

    var id: String { rawValue }

    var title: String {
        switch self {
        case .swipeDetents:
            "Свайп"
        case .pressMenu:
            "Меню"
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
        static let personalCartMarkers = "personalCartMarkers"
        static let personalCartMarkerInputMode = "personalCartMarkerInputMode"
        static let cartConsumableCatalog = "cartConsumableCatalog"
        static let statusPaletteSaturation = "statusPaletteSaturation"
        static let matrixSpeed = "matrixSpeed"
        static let backgroundVideoRelativePath = "backgroundVideoRelativePath"
        static let backgroundVideoBlur = "backgroundVideoBlur"
        static let backgroundVideoBrightness = "backgroundVideoBrightness"
        static let backgroundVideoGreenTint = "backgroundVideoGreenTint"
        static let backgroundVideoGridIntensity = "backgroundVideoGridIntensity"
        static let activeAIVisualPresetID = "activeAIVisualPresetID"
        static let tvStaticVariant = "tvStaticVariant"
        static let tvStaticSpeed = "tvStaticSpeed"
        static let tvStaticParticleSize = "tvStaticParticleSize"
        static let tvStaticBrightness = "tvStaticBrightness"
        static let tvStaticGreenTint = "tvStaticGreenTint"
        static let developerCellPhysicsEnabled = "developerCellPhysicsEnabled"
        static let developerCellSpringIntensity = "developerCellSpringIntensity"
        static let developerCellSpringSpeed = "developerCellSpringSpeed"
        static let deepSeekModelTier = "deepSeekModelTier"
        static let developerVIPFlickerEnabled = "developerVIPFlickerEnabled"
        static let developerVIPFlickerSpeed = "developerVIPFlickerSpeed"
        // Keep the old key names so existing installs migrate VIP breathing into the replacement VIP jelly mode.
        static let developerVIPJellyEnabled = "developerVIPBreathingEnabled"
        static let developerVIPJellySpeed = "developerVIPBreathingSpeed"
        static let developerVIPJellyDefaultEnabledMigration = "developerVIPJellyDefaultEnabledMigration_v94"
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
    private var storedDeveloperVIPFlickerSpeed: Double
    private var storedDeveloperVIPJellySpeed: Double
    var deepSeekModelTier: DeepSeekModelTier {
        didSet {
            userDefaults.set(deepSeekModelTier.rawValue, forKey: Keys.deepSeekModelTier)
        }
    }

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

    var personalCartMarkers: PersonalCartMarkers {
        didSet {
            Self.savePersonalCartMarkers(personalCartMarkers, userDefaults: userDefaults)
        }
    }

    var personalCartMarkerInputMode: PersonalCartMarkerInputMode {
        didSet {
            userDefaults.set(personalCartMarkerInputMode.rawValue, forKey: Keys.personalCartMarkerInputMode)
        }
    }

    var cartConsumableCatalog: [CartConsumableCatalogEntry] {
        didSet {
            Self.saveCartConsumableCatalog(
                CartConsumableCatalog.normalizedEntries(cartConsumableCatalog),
                userDefaults: userDefaults
            )
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

    var activeAIVisualPresetID: UUID? {
        didSet {
            userDefaults.set(activeAIVisualPresetID?.uuidString, forKey: Keys.activeAIVisualPresetID)
        }
    }

    var tvStaticVariant: TVStaticNoiseVariant {
        didSet {
            userDefaults.set(tvStaticVariant.rawValue, forKey: Keys.tvStaticVariant)
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

    var developerVIPFlickerEnabled: Bool {
        didSet {
            userDefaults.set(developerVIPFlickerEnabled, forKey: Keys.developerVIPFlickerEnabled)
        }
    }

    var developerVIPJellyEnabled: Bool {
        didSet {
            userDefaults.set(developerVIPJellyEnabled, forKey: Keys.developerVIPJellyEnabled)
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

    var developerVIPFlickerSpeed: Double {
        get { storedDeveloperVIPFlickerSpeed }
        set {
            storedDeveloperVIPFlickerSpeed = Self.normalizedDeveloperVIPFlickerSpeed(newValue)
            userDefaults.set(storedDeveloperVIPFlickerSpeed, forKey: Keys.developerVIPFlickerSpeed)
        }
    }

    var developerVIPJellySpeed: Double {
        get { storedDeveloperVIPJellySpeed }
        set {
            storedDeveloperVIPJellySpeed = Self.normalizedDeveloperVIPJellySpeed(newValue)
            userDefaults.set(storedDeveloperVIPJellySpeed, forKey: Keys.developerVIPJellySpeed)
        }
    }

    var matrixConfiguration: MatrixRainConfiguration {
        MatrixRainConfiguration(speed: matrixSpeed)
    }

    var tvStaticNoiseConfiguration: TVStaticNoiseConfiguration {
        TVStaticNoiseConfiguration(
            variant: tvStaticVariant,
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
        personalCartMarkers = .default
        personalCartMarkerInputMode = .swipeDetents
        cartConsumableCatalog = CartConsumableCatalog.defaultEntries
        statusPaletteSaturation = 1
        matrixSpeed = MatrixRainConfiguration.default.speed
        backgroundVideoRelativePath = nil
        backgroundVideoBlur = 0.28
        backgroundVideoBrightness = 0.08
        backgroundVideoGreenTint = 0.34
        backgroundVideoGridIntensity = 0
        activeAIVisualPresetID = nil
        tvStaticVariant = TVStaticNoiseConfiguration.default.variant
        tvStaticSpeed = TVStaticNoiseConfiguration.default.speed
        tvStaticParticleSize = TVStaticNoiseConfiguration.default.particleSize
        tvStaticBrightness = TVStaticNoiseConfiguration.default.brightness
        tvStaticGreenTint = TVStaticNoiseConfiguration.default.greenTint
        developerCellPhysicsEnabled = false
        developerCellSpringIntensity = 0.72
        developerCellSpringSpeed = 0.82
        deepSeekModelTier = .pro
        developerVIPFlickerEnabled = false
        developerVIPFlickerSpeed = 1.6
        developerVIPJellyEnabled = true
        developerVIPJellySpeed = 0.75
    }

    init(
        appBackgroundMode: AppBackgroundMode = .matrixRain,
        roomCellGeometry: RoomCellGeometry = .roomy,
        roomTaskLongPress: Bool = true,
        summaryActionMenuAllowsMultiple: Bool = false,
        personalCartMarkers: PersonalCartMarkers = .default,
        personalCartMarkerInputMode: PersonalCartMarkerInputMode = .swipeDetents,
        cartConsumableCatalog: [CartConsumableCatalogEntry] = CartConsumableCatalog.defaultEntries,
        statusPaletteSaturation: Double = 1,
        matrixSpeed: Double = MatrixRainConfiguration.default.speed,
        backgroundVideoRelativePath: String? = nil,
        backgroundVideoBlur: Double = 0.28,
        backgroundVideoBrightness: Double = 0.08,
        backgroundVideoGreenTint: Double = 0.34,
        backgroundVideoGridIntensity: Double = 0,
        activeAIVisualPresetID: UUID? = nil,
        tvStaticVariant: TVStaticNoiseVariant = TVStaticNoiseConfiguration.default.variant,
        tvStaticSpeed: Double = TVStaticNoiseConfiguration.default.speed,
        tvStaticParticleSize: Double = TVStaticNoiseConfiguration.default.particleSize,
        tvStaticBrightness: Double = TVStaticNoiseConfiguration.default.brightness,
        tvStaticGreenTint: Double = TVStaticNoiseConfiguration.default.greenTint,
        developerCellPhysicsEnabled: Bool = false,
        developerCellSpringIntensity: Double = 0.72,
        developerCellSpringSpeed: Double = 0.82,
        deepSeekModelTier: DeepSeekModelTier = .pro,
        developerVIPFlickerEnabled: Bool = false,
        developerVIPFlickerSpeed: Double = 1.6,
        developerVIPJellyEnabled: Bool = true,
        developerVIPJellySpeed: Double = 0.75,
        userDefaults: UserDefaults = .standard
    ) {
        self.appBackgroundMode = appBackgroundMode
        self.roomCellGeometry = roomCellGeometry
        self.roomTaskLongPress = roomTaskLongPress
        self.summaryActionMenuAllowsMultiple = summaryActionMenuAllowsMultiple
        self.personalCartMarkers = personalCartMarkers.normalized()
        self.personalCartMarkerInputMode = personalCartMarkerInputMode
        self.cartConsumableCatalog = CartConsumableCatalog.normalizedEntries(cartConsumableCatalog)
        self.backgroundVideoRelativePath = backgroundVideoRelativePath
        self.activeAIVisualPresetID = activeAIVisualPresetID
        self.tvStaticVariant = tvStaticVariant
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
        self.storedDeveloperVIPFlickerSpeed = Self.normalizedDeveloperVIPFlickerSpeed(developerVIPFlickerSpeed)
        self.storedDeveloperVIPJellySpeed = Self.normalizedDeveloperVIPJellySpeed(developerVIPJellySpeed)
        self.developerCellPhysicsEnabled = developerCellPhysicsEnabled
        self.deepSeekModelTier = deepSeekModelTier
        self.developerVIPFlickerEnabled = developerVIPFlickerEnabled
        self.developerVIPJellyEnabled = developerVIPJellyEnabled
        self.userDefaults = userDefaults
    }

    static func load(userDefaults: UserDefaults = .standard) -> AppSettingsStore {
        let backgroundRawValue = userDefaults.string(forKey: Keys.appBackgroundMode)
        let appBackgroundMode = backgroundRawValue.flatMap(AppBackgroundMode.init(rawValue:)) ?? .matrixRain
        let rawValue = userDefaults.string(forKey: Keys.roomCellGeometry)
        let geometry = rawValue.flatMap(RoomCellGeometry.init(rawValue:)) ?? .roomy
        let roomTaskLongPress = userDefaults.object(forKey: Keys.roomTaskLongPress) as? Bool ?? true
        let summaryActionMenuAllowsMultiple = userDefaults.object(forKey: Keys.summaryActionMenuAllowsMultiple) as? Bool ?? false
        let personalCartMarkers = Self.loadPersonalCartMarkers(userDefaults: userDefaults)
        let personalCartMarkerInputMode = userDefaults.string(forKey: Keys.personalCartMarkerInputMode)
            .flatMap(PersonalCartMarkerInputMode.init(rawValue:))
            ?? .swipeDetents
        let cartConsumableCatalog = Self.loadCartConsumableCatalog(userDefaults: userDefaults)
        let statusPaletteSaturation = userDefaults.object(forKey: Keys.statusPaletteSaturation) as? Double ?? 1
        let matrixSpeed = userDefaults.object(forKey: Keys.matrixSpeed) as? Double
            ?? MatrixRainConfiguration.default.speed
        let backgroundVideoRelativePath = userDefaults.string(forKey: Keys.backgroundVideoRelativePath)
        let backgroundVideoBlur = userDefaults.object(forKey: Keys.backgroundVideoBlur) as? Double ?? 0.28
        let backgroundVideoBrightness = userDefaults.object(forKey: Keys.backgroundVideoBrightness) as? Double ?? 0.08
        let backgroundVideoGreenTint = userDefaults.object(forKey: Keys.backgroundVideoGreenTint) as? Double ?? 0.34
        let backgroundVideoGridIntensity = userDefaults.object(forKey: Keys.backgroundVideoGridIntensity) as? Double ?? 0
        let activeAIVisualPresetID = userDefaults.string(forKey: Keys.activeAIVisualPresetID).flatMap(UUID.init(uuidString:))
        let tvStaticSpeed = userDefaults.object(forKey: Keys.tvStaticSpeed) as? Double
            ?? TVStaticNoiseConfiguration.default.speed
        let tvStaticParticleSize = userDefaults.object(forKey: Keys.tvStaticParticleSize) as? Double
            ?? TVStaticNoiseConfiguration.default.particleSize
        let tvStaticBrightness = userDefaults.object(forKey: Keys.tvStaticBrightness) as? Double
            ?? TVStaticNoiseConfiguration.default.brightness
        let tvStaticGreenTint = userDefaults.object(forKey: Keys.tvStaticGreenTint) as? Double
            ?? TVStaticNoiseConfiguration.default.greenTint
        let tvStaticVariant = userDefaults.string(forKey: Keys.tvStaticVariant)
            .flatMap(TVStaticNoiseVariant.init(rawValue:))
            ?? TVStaticNoiseConfiguration.default.variant
        let developerCellPhysicsEnabled = userDefaults.object(forKey: Keys.developerCellPhysicsEnabled) as? Bool ?? false
        let developerCellSpringIntensity = userDefaults.object(forKey: Keys.developerCellSpringIntensity) as? Double ?? 0.72
        let developerCellSpringSpeed = userDefaults.object(forKey: Keys.developerCellSpringSpeed) as? Double ?? 0.82
        let deepSeekModelTier = userDefaults.string(forKey: Keys.deepSeekModelTier)
            .flatMap(DeepSeekModelTier.init(rawValue:))
            ?? .pro
        let developerVIPFlickerEnabled = userDefaults.object(forKey: Keys.developerVIPFlickerEnabled) as? Bool ?? false
        let developerVIPFlickerSpeed = userDefaults.object(forKey: Keys.developerVIPFlickerSpeed) as? Double ?? 1.6
        let developerVIPJellyEnabled = Self.migratedDeveloperVIPJellyEnabled(userDefaults: userDefaults)
        let developerVIPJellySpeed = userDefaults.object(forKey: Keys.developerVIPJellySpeed) as? Double ?? 0.75
        return AppSettingsStore(
            appBackgroundMode: appBackgroundMode,
            roomCellGeometry: geometry,
            roomTaskLongPress: roomTaskLongPress,
            summaryActionMenuAllowsMultiple: summaryActionMenuAllowsMultiple,
            personalCartMarkers: personalCartMarkers,
            personalCartMarkerInputMode: personalCartMarkerInputMode,
            cartConsumableCatalog: cartConsumableCatalog,
            statusPaletteSaturation: statusPaletteSaturation,
            matrixSpeed: matrixSpeed,
            backgroundVideoRelativePath: backgroundVideoRelativePath,
            backgroundVideoBlur: backgroundVideoBlur,
            backgroundVideoBrightness: backgroundVideoBrightness,
            backgroundVideoGreenTint: backgroundVideoGreenTint,
            backgroundVideoGridIntensity: backgroundVideoGridIntensity,
            activeAIVisualPresetID: activeAIVisualPresetID,
            tvStaticVariant: tvStaticVariant,
            tvStaticSpeed: tvStaticSpeed,
            tvStaticParticleSize: tvStaticParticleSize,
            tvStaticBrightness: tvStaticBrightness,
            tvStaticGreenTint: tvStaticGreenTint,
            developerCellPhysicsEnabled: developerCellPhysicsEnabled,
            developerCellSpringIntensity: developerCellSpringIntensity,
            developerCellSpringSpeed: developerCellSpringSpeed,
            deepSeekModelTier: deepSeekModelTier,
            developerVIPFlickerEnabled: developerVIPFlickerEnabled,
            developerVIPFlickerSpeed: developerVIPFlickerSpeed,
            developerVIPJellyEnabled: developerVIPJellyEnabled,
            developerVIPJellySpeed: developerVIPJellySpeed,
            userDefaults: userDefaults
        )
    }

    static func normalizedStatusPaletteSaturation(_ value: Double) -> Double {
        min(max(value, 0.70), 1.65)
    }

    private static func migratedDeveloperVIPJellyEnabled(userDefaults: UserDefaults) -> Bool {
        if userDefaults.bool(forKey: Keys.developerVIPJellyDefaultEnabledMigration) {
            return userDefaults.object(forKey: Keys.developerVIPJellyEnabled) as? Bool ?? true
        }
        userDefaults.set(true, forKey: Keys.developerVIPJellyEnabled)
        userDefaults.set(true, forKey: Keys.developerVIPJellyDefaultEnabledMigration)
        return true
    }

    private static func loadPersonalCartMarkers(userDefaults: UserDefaults) -> PersonalCartMarkers {
        guard let data = userDefaults.data(forKey: Keys.personalCartMarkers),
              let decoded = try? JSONDecoder().decode(PersonalCartMarkers.self, from: data)
        else {
            return .default
        }
        return decoded.normalized()
    }

    private static func savePersonalCartMarkers(_ markers: PersonalCartMarkers, userDefaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(markers.normalized()) else { return }
        userDefaults.set(data, forKey: Keys.personalCartMarkers)
    }

    private static func loadCartConsumableCatalog(userDefaults: UserDefaults) -> [CartConsumableCatalogEntry] {
        guard let data = userDefaults.data(forKey: Keys.cartConsumableCatalog),
              let decoded = try? JSONDecoder().decode([CartConsumableCatalogEntry].self, from: data)
        else {
            return CartConsumableCatalog.defaultEntries
        }
        return CartConsumableCatalog.normalizedEntries(decoded)
    }

    private static func saveCartConsumableCatalog(
        _ catalog: [CartConsumableCatalogEntry],
        userDefaults: UserDefaults
    ) {
        guard let data = try? JSONEncoder().encode(CartConsumableCatalog.normalizedEntries(catalog)) else { return }
        userDefaults.set(data, forKey: Keys.cartConsumableCatalog)
    }

    func addCartConsumableCatalogItem(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var catalog = cartConsumableCatalog
        catalog.append(
            CartConsumableCatalogEntry(
                id: "custom_\(UUID().uuidString)",
                title: trimmed
            )
        )
        cartConsumableCatalog = catalog
    }

    func renameCartConsumableCatalogItem(
        itemID: CartConsumableItem.ID,
        title: String
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var catalog = cartConsumableCatalog
        if let index = catalog.firstIndex(where: { $0.id == itemID }) {
            guard catalog[index].title != trimmed else { return }
            catalog[index].title = trimmed
            catalog[index].isHidden = false
        } else {
            catalog.append(CartConsumableCatalogEntry(id: itemID, title: trimmed))
        }
        cartConsumableCatalog = catalog
    }

    func removeCartConsumableCatalogItem(itemID: CartConsumableItem.ID) {
        var catalog = cartConsumableCatalog
        if let index = catalog.firstIndex(where: { $0.id == itemID }) {
            catalog[index].isHidden = true
        } else if let defaultEntry = CartConsumableCatalog.defaultEntries.first(where: { $0.id == itemID }) {
            var hiddenEntry = defaultEntry
            hiddenEntry.isHidden = true
            catalog.append(hiddenEntry)
        }
        cartConsumableCatalog = catalog
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
        min(max(value, -1), 1)
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

    static func normalizedDeveloperVIPFlickerSpeed(_ value: Double) -> Double {
        min(max(value, 0.4), 4.0)
    }

    static func normalizedDeveloperVIPJellySpeed(_ value: Double) -> Double {
        min(max(value, 0.2), 2.5)
    }
}
