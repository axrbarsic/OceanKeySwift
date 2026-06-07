import SwiftUI

struct SummaryScreen: View {
    @Bindable var workSession: WorkSessionStore

    var body: some View {
        ZStack {
            MatrixRainBackground()
                .ignoresSafeArea()

            VStack(spacing: 18) {
                SummaryHeader(counts: workSession.counts)

                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach($workSession.carts) { $cart in
                            CartSummarySection(
                                cart: $cart,
                                onTaskToggle: workSession.toggleTask,
                                onVIPToggle: workSession.toggleVIP
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.top, 18)
        }
    }
}

#Preview {
    SummaryScreen(workSession: .preview())
}
