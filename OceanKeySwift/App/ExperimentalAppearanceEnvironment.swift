import SwiftUI

private struct ExperimentalCellPhysicsEnabledKey: EnvironmentKey {
    static let defaultValue = false
}

private struct ExperimentalCellSpringIntensityKey: EnvironmentKey {
    static let defaultValue = 0.72
}

private struct ExperimentalCellSpringSpeedKey: EnvironmentKey {
    static let defaultValue = 0.82
}

private struct ExperimentalVIPFlickerEnabledKey: EnvironmentKey {
    static let defaultValue = false
}

private struct ExperimentalVIPFlickerSpeedKey: EnvironmentKey {
    static let defaultValue = 1.6
}

private struct ExperimentalVIPBreathingEnabledKey: EnvironmentKey {
    static let defaultValue = false
}

private struct ExperimentalVIPBreathingSpeedKey: EnvironmentKey {
    static let defaultValue = 0.75
}

extension EnvironmentValues {
    var experimentalCellPhysicsEnabled: Bool {
        get { self[ExperimentalCellPhysicsEnabledKey.self] }
        set { self[ExperimentalCellPhysicsEnabledKey.self] = newValue }
    }

    var experimentalCellSpringIntensity: Double {
        get { self[ExperimentalCellSpringIntensityKey.self] }
        set { self[ExperimentalCellSpringIntensityKey.self] = newValue }
    }

    var experimentalCellSpringSpeed: Double {
        get { self[ExperimentalCellSpringSpeedKey.self] }
        set { self[ExperimentalCellSpringSpeedKey.self] = newValue }
    }

    var experimentalVIPFlickerEnabled: Bool {
        get { self[ExperimentalVIPFlickerEnabledKey.self] }
        set { self[ExperimentalVIPFlickerEnabledKey.self] = newValue }
    }

    var experimentalVIPFlickerSpeed: Double {
        get { self[ExperimentalVIPFlickerSpeedKey.self] }
        set { self[ExperimentalVIPFlickerSpeedKey.self] = newValue }
    }

    var experimentalVIPBreathingEnabled: Bool {
        get { self[ExperimentalVIPBreathingEnabledKey.self] }
        set { self[ExperimentalVIPBreathingEnabledKey.self] = newValue }
    }

    var experimentalVIPBreathingSpeed: Double {
        get { self[ExperimentalVIPBreathingSpeedKey.self] }
        set { self[ExperimentalVIPBreathingSpeedKey.self] = newValue }
    }
}
