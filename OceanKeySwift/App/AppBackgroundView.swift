import SwiftUI

struct AppBackgroundView: View {
    @Environment(\.appBackgroundMode) private var appBackgroundMode

    var body: some View {
        ZStack {
            Color.black
            if appBackgroundMode == .matrixRain {
                SpriteKitEffectView(.matrixRain)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackgroundView()
        .environment(\.appBackgroundMode, .matrixRain)
        .environment(\.matrixRainConfiguration, .default)
}
