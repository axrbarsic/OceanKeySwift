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
                                onTaskToggle: toggleTask,
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
        feedback.playEvent(.settingsOpen)
        isSettingsPresented = true
    }

    private func openSelection() {
        feedback.playEvent(.selectionOpen)
        workSession.unlockWorkdayForEditing()
    }

    private func toggleOpen(roomID: RoomCell.ID) {
        let previousStatus = workSession.room(id: roomID)?.status
        let hadSchedule = workSession.room(id: roomID)?.scheduledTime != nil
        workSession.toggleOpen(roomId: roomID)
        playRoomStatusChange(roomID: roomID, previousStatus: previousStatus)
        if hadSchedule, workSession.room(id: roomID)?.scheduledTime == nil {
            scheduleNotifications.cancelRoom(roomID)
        }
    }

    private func toggleTask(_ task: RoomTask, roomID: RoomCell.ID) {
        let previousStatus = workSession.room(id: roomID)?.status
        workSession.toggleTask(task, roomId: roomID)
        playRoomStatusChange(roomID: roomID, previousStatus: previousStatus)
    }

    private func openSchedule(roomID: RoomCell.ID) {
        scheduleRoute = RoomScheduleRoute(
            roomID: roomID,
            initialDate: workSession.room(id: roomID)?.scheduledTime
        )
    }

    private func setSchedule(roomID: RoomCell.ID, dueAt: Date) {
        let previousStatus = workSession.room(id: roomID)?.status
        workSession.setSchedule(dueAt, roomId: roomID)
        expandedActionMenuRoomIDs.remove(roomID)
        if dueAt <= Date() {
            advanceScheduledRooms()
        } else {
            playRoomStatusChange(roomID: roomID, previousStatus: previousStatus)
            scheduleNotifications.scheduleRoom(roomID, dueAt)
        }
    }

    private func clearSchedule(roomID: RoomCell.ID) {
        let previousStatus = workSession.room(id: roomID)?.status
        workSession.setSchedule(nil, roomId: roomID)
        expandedActionMenuRoomIDs.remove(roomID)
        playRoomStatusChange(roomID: roomID, previousStatus: previousStatus)
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
            playRoomStatusChange(roomID: roomID, previousStatus: .scheduled)
            scheduleNotifications.cancelRoom(roomID)
        }
    }

    private func playRoomStatusChange(roomID: RoomCell.ID, previousStatus: RoomStatus?) {
        guard let nextStatus = workSession.room(id: roomID)?.status,
              nextStatus != previousStatus
        else { return }
        feedback.playEvent(nextStatus.interactionSoundEvent)
    }
}

private extension RoomStatus {
    var interactionSoundEvent: InteractionSoundEvent {
        switch self {
        case .pending: .roomPending
        case .open: .roomOpen
        case .inProgress: .roomInProgress
        case .ready: .roomReady
        case .scheduled: .roomScheduled
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
