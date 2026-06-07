import SwiftUI

struct AppRootView: View {
    @Bindable var workSession: WorkSessionStore
    @Bindable var appSettings: AppSettingsStore

    var body: some View {
        NavigationStack {
            SummaryScreen(workSession: workSession, appSettings: appSettings)
        }
        .preferredColorScheme(.dark)
    }
}
