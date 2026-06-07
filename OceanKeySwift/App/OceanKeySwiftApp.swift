import SwiftUI

@main
struct OceanKeySwiftApp: App {
    @State private var workSession = WorkSessionStore.preview()

    var body: some Scene {
        WindowGroup {
            AppRootView(workSession: workSession)
        }
    }
}
