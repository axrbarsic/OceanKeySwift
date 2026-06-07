import SwiftUI

struct AppRootView: View {
    @Bindable var workSession: WorkSessionStore

    var body: some View {
        NavigationStack {
            SummaryScreen(workSession: workSession)
        }
        .preferredColorScheme(.dark)
    }
}
