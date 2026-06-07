import SwiftUI

struct SummaryScreen: View {
    private let scheduleTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    @Bindable var workSession: WorkSessionStore
    @Bindable var appSettings: AppSettingsStore
    @Environment(\.interactionFeedback) private var feedback
    @State private var expandedActionMenuRoomID: RoomCell.ID?
    @State private var roomDetailsRoute: RoomDetailsRoute?
    @State private var cartDetailsRoute: CartDetailsRoute?
    @State private var isSettingsPresented = false

    var body: some View {
        ZStack {
            SpriteKitEffectView(.matrixRain)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                SummaryHeader(
                    counts: workSession.counts,
                    onOpenSettings: openSettings
                )

                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach($workSession.carts) { $cart in
                            CartSummarySection(
                                cart: $cart,
                                geometry: appSettings.roomCellGeometry,
                                taskControlsUseLongPress: appSettings.roomTaskLongPress,
                                expandedActionMenuRoomID: $expandedActionMenuRoomID,
                                onOpenCartDetails: { cartID in
                                    expandedActionMenuRoomID = nil
                                    cartDetailsRoute = CartDetailsRoute(cartID: cartID)
                                },
                                onOpenDetails: { roomID, mode in
                                    expandedActionMenuRoomID = nil
                                    roomDetailsRoute = RoomDetailsRoute(roomID: roomID, mode: mode)
                                },
                                onOpenToggle: workSession.toggleOpen,
                                onTaskToggle: workSession.toggleTask,
                                onVIPToggle: workSession.toggleVIP,
                                onScheduleToggle: workSession.toggleSchedule
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
        .sheet(item: $roomDetailsRoute) { route in
            RoomDetailsScreen(route: route, workSession: workSession)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $cartDetailsRoute) { route in
            CartDetailsScreen(route: route, workSession: workSession)
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsScreen(workSession: workSession, appSettings: appSettings)
                .preferredColorScheme(.dark)
        }
        .onAppear {
            workSession.advanceScheduledRooms()
        }
        .onReceive(scheduleTimer) { date in
            workSession.advanceScheduledRooms(now: date)
        }
    }

    private func openSettings() {
        feedback.tap()
        isSettingsPresented = true
    }
}

#Preview {
    SummaryScreen(workSession: .preview(), appSettings: AppSettingsStore())
}
