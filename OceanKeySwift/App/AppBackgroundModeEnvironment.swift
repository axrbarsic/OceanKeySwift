import SwiftUI

private struct AppBackgroundModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppBackgroundMode = .matrixRain
}

private struct TVStaticNoiseConfigurationEnvironmentKey: EnvironmentKey {
    static let defaultValue: TVStaticNoiseConfiguration = .default
}

private struct ActiveAIVisualPresetEnvironmentKey: EnvironmentKey {
    static let defaultValue: AIVisualPreset? = nil
}

extension EnvironmentValues {
    var appBackgroundMode: AppBackgroundMode {
        get { self[AppBackgroundModeEnvironmentKey.self] }
        set { self[AppBackgroundModeEnvironmentKey.self] = newValue }
    }

    var tvStaticNoiseConfiguration: TVStaticNoiseConfiguration {
        get { self[TVStaticNoiseConfigurationEnvironmentKey.self] }
        set { self[TVStaticNoiseConfigurationEnvironmentKey.self] = newValue }
    }

    var activeAIVisualPreset: AIVisualPreset? {
        get { self[ActiveAIVisualPresetEnvironmentKey.self] }
        set { self[ActiveAIVisualPresetEnvironmentKey.self] = newValue }
    }
}
