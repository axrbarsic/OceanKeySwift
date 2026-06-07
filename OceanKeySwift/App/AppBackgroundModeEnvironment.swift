import SwiftUI

private struct AppBackgroundModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppBackgroundMode = .matrixRain
}

extension EnvironmentValues {
    var appBackgroundMode: AppBackgroundMode {
        get { self[AppBackgroundModeEnvironmentKey.self] }
        set { self[AppBackgroundModeEnvironmentKey.self] = newValue }
    }
}
