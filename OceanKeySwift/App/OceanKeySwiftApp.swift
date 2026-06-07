import SwiftUI

@main
struct OceanKeySwiftApp: App {
    @State private var workSession = WorkSessionStore.load()
    @State private var appSettings = AppSettingsStore.load()
    private let interactionFeedback = InteractionFeedbackService()

    var body: some Scene {
        WindowGroup {
            AppRootView(workSession: workSession, appSettings: appSettings)
                .environment(\.interactionFeedback, .live(interactionFeedback))
        }
    }
}
