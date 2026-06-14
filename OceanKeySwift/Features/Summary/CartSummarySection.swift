import SwiftUI

struct CartSummarySection: View {
    @Environment(\.interactionFeedback) private var feedback

    @Binding var cart: CartSection
    let geometry: RoomCellGeometry
    let taskControlsUseLongPress: Bool
    let statusPaletteSaturation: Double
    let actionMenuAllowsMultiple: Bool
    @Binding var expandedActionMenuRoomIDs: Set<RoomCell.ID>
    let onOpenCartDetails: (CartSection.ID) -> Void
    let onOpenDetails: (RoomCell.ID, RoomDetailsMode) -> Void
    let onOpenToggle: (RoomCell.ID) -> Void
    let onTaskToggle: (RoomTask, RoomCell.ID) -> Void
    let onVIPToggle: (RoomCell.ID) -> Void
    let onScheduleToggle: (RoomCell.ID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: geometry.sectionSpacing) {
            HStack(alignment: .center, spacing: 8) {
                Label("Тележка \(cart.id)", systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                    .layoutPriority(3)

                if let consumableTickerText {
                    CartConsumableTicker(text: consumableTickerText)
                        .frame(minWidth: 72, maxWidth: .infinity)
                        .layoutPriority(1)
                } else {
                    Spacer(minLength: 8)
                }

                Text(cart.building)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .layoutPriority(4)
            }
            .font(.system(size: 30, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.bottom, 3)
            .contentShape(Rectangle())
            .onLongPressGesture {
                feedback.longPress()
                onOpenCartDetails(cart.id)
            }

            ForEach($cart.rooms) { $room in
                RoomCellView(
                    room: $room,
                    geometry: geometry,
                    taskControlsUseLongPress: taskControlsUseLongPress,
                    statusPaletteSaturation: statusPaletteSaturation,
                    isActionMenuExpanded: expandedActionMenuRoomIDs.contains(room.id),
                    onActionMenuToggle: {
                        expandedActionMenuRoomIDs = SummaryActionMenuExpansion.toggled(
                            roomID: room.id,
                            in: expandedActionMenuRoomIDs,
                            allowsMultiple: actionMenuAllowsMultiple
                        )
                    },
                    onOpenMultimodalNote: { onOpenDetails(room.id, .voice) },
                    onOpenToggle: { onOpenToggle(room.id) },
                    onTaskToggle: { task in onTaskToggle(task, room.id) },
                    onVIPToggle: {
                        onVIPToggle(room.id)
                        closeActionMenu(room.id)
                    },
                    onScheduleToggle: { onScheduleToggle(room.id) }
                )
            }
        }
        .padding(.horizontal, geometry.sectionHorizontalPadding)
    }

    private func closeActionMenu(_ roomID: RoomCell.ID) {
        expandedActionMenuRoomIDs.remove(roomID)
    }

    private var consumableTickerText: String? {
        CartConsumableTickerFormatter.text(for: cart)
    }
}

#Preview {
    @Previewable @State var cart = WorkSessionStore.preview().carts[0]
    @Previewable @State var expanded: Set<RoomCell.ID> = []
    return CartSummarySection(
        cart: $cart,
        geometry: .roomy,
        taskControlsUseLongPress: true,
        statusPaletteSaturation: 1,
        actionMenuAllowsMultiple: false,
        expandedActionMenuRoomIDs: $expanded,
        onOpenCartDetails: { _ in },
        onOpenDetails: { _, _ in },
        onOpenToggle: { _ in },
        onTaskToggle: { _, _ in },
        onVIPToggle: { _ in },
        onScheduleToggle: { _ in }
    )
        .background(OceanKeyTheme.background)
}
