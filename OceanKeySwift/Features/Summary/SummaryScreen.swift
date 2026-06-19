import SwiftUI

struct SummaryScreen: View {
    private let scheduleTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    @Bindable var workSession: WorkSessionStore
    @Bindable var appSettings: AppSettingsStore
    @Bindable var aiVisualPresetStore: AIVisualPresetStore
    @Bindable var performanceTelemetry: PerformanceTelemetryStore
    @Environment(\.interactionFeedback) private var feedback
    @Environment(\.scheduleNotifications) private var scheduleNotifications
    @State private var expandedActionMenuRoomIDs: Set<RoomCell.ID> = []
    @State private var roomDetailsRoute: RoomDetailsRoute?
    @State private var cartDetailsRoute: CartDetailsRoute?
    @State private var scheduleRoute: RoomScheduleRoute?
    @State private var isSettingsPresented = false

    var body: some View {
        ZStack {
            if isSettingsPresented {
                Color.black.ignoresSafeArea()
            } else {
                AppBackgroundView()
            }

            VStack(spacing: 18) {
                SummaryHeader(
                    counts: workSession.counts,
                    personalCartMarkers: $appSettings.personalCartMarkers,
                    personalCartMarkerInputMode: appSettings.personalCartMarkerInputMode,
                    onOpenSettings: openSettings,
                    onOpenSelection: openSelection
                )

                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach($workSession.carts) { $cart in
                            CartSummarySection(
                                cart: $cart,
                                geometry: appSettings.roomCellGeometry,
                                taskControlsUseLongPress: appSettings.roomTaskLongPress,
                                statusPaletteSaturation: appSettings.statusPaletteSaturation,
                                consumableCatalog: appSettings.cartConsumableCatalog,
                                actionMenuAllowsMultiple: appSettings.summaryActionMenuAllowsMultiple,
                                expandedActionMenuRoomIDs: $expandedActionMenuRoomIDs,
                                onOpenCartDetails: { cartID in
                                    expandedActionMenuRoomIDs.removeAll()
                                    cartDetailsRoute = CartDetailsRoute(cartID: cartID)
                                },
                                onOpenDetails: { roomID, mode in
                                    roomDetailsRoute = RoomDetailsRoute(roomID: roomID, mode: mode)
                                },
                                onOpenToggle: toggleOpen,
                                onTaskToggle: workSession.toggleTask,
                                onVIPToggle: workSession.toggleVIP,
                                onScheduleToggle: openSchedule
                            )
                        }

                        CartConsumablesSummaryTable(
                            report: CartConsumablesSummaryBuilder.report(
                                for: workSession.carts,
                                catalogEntries: appSettings.cartConsumableCatalog
                            ),
                            onQuantityChange: updateConsumableFromSummary
                        )
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.top, 18)

        }
        .sheet(item: $roomDetailsRoute, onDismiss: closeActionMenus) { route in
            RoomDetailsScreen(route: route, workSession: workSession)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $cartDetailsRoute) { route in
            CartDetailsScreen(route: route, workSession: workSession, appSettings: appSettings)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $scheduleRoute) { route in
            RoomScheduleSheet(route: route, onSet: setSchedule, onClear: clearSchedule)
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsScreen(
                appSettings: appSettings,
                aiVisualPresetStore: aiVisualPresetStore
            )
                .preferredColorScheme(.dark)
        }
        .onAppear {
            advanceScheduledRooms()
        }
        .onChange(of: appSettings.summaryActionMenuAllowsMultiple) { _, allowsMultiple in
            expandedActionMenuRoomIDs = SummaryActionMenuExpansion.normalized(
                expandedActionMenuRoomIDs,
                allowsMultiple: allowsMultiple
            )
        }
        .onReceive(scheduleTimer) { date in
            advanceScheduledRooms(now: date)
        }
    }

    private func openSettings() {
        isSettingsPresented = true
    }

    private func openSelection() {
        feedback.confirm()
        workSession.unlockWorkdayForEditing()
    }

    private func toggleOpen(roomID: RoomCell.ID) {
        let hadSchedule = workSession.room(id: roomID)?.scheduledTime != nil
        workSession.toggleOpen(roomId: roomID)
        if hadSchedule, workSession.room(id: roomID)?.scheduledTime == nil {
            scheduleNotifications.cancelRoom(roomID)
        }
    }

    private func openSchedule(roomID: RoomCell.ID) {
        scheduleRoute = RoomScheduleRoute(
            roomID: roomID,
            initialDate: workSession.room(id: roomID)?.scheduledTime
        )
    }

    private func setSchedule(roomID: RoomCell.ID, dueAt: Date) {
        workSession.setSchedule(dueAt, roomId: roomID)
        expandedActionMenuRoomIDs.remove(roomID)
        if dueAt <= Date() {
            advanceScheduledRooms()
        } else {
            scheduleNotifications.scheduleRoom(roomID, dueAt)
        }
    }

    private func clearSchedule(roomID: RoomCell.ID) {
        workSession.setSchedule(nil, roomId: roomID)
        expandedActionMenuRoomIDs.remove(roomID)
        scheduleNotifications.cancelRoom(roomID)
    }

    private func updateConsumableFromSummary(
        cartID: CartSection.ID,
        itemID: CartConsumableItem.ID,
        title: String,
        quantity: Int
    ) {
        workSession.updateCartConsumableQuantity(
            itemID: itemID,
            title: title,
            quantity: quantity,
            cartId: cartID
        )
    }

    private func closeActionMenus() {
        expandedActionMenuRoomIDs.removeAll()
    }

    private func advanceScheduledRooms(now: Date = Date()) {
        let openedRoomIDs = workSession.advanceScheduledRooms(now: now)
        for roomID in openedRoomIDs {
            scheduleNotifications.cancelRoom(roomID)
        }
    }
}

#Preview {
    SummaryScreen(
        workSession: .preview(),
        appSettings: AppSettingsStore(),
        aiVisualPresetStore: try! AIVisualPresetStore(inMemory: true),
        performanceTelemetry: PerformanceTelemetryStore()
    )
}
