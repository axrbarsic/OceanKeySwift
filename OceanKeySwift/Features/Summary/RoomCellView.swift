import SwiftUI

struct RoomCellView: View {
    @Environment(\.interactionFeedback) private var feedback

    @Binding var room: RoomCell
    let geometry: RoomCellGeometry
    let taskControlsUseLongPress: Bool
    let isActionMenuExpanded: Bool
    let onActionMenuToggle: () -> Void
    let onOpenNotes: () -> Void
    let onOpenVoice: () -> Void
    let onOpenMedia: () -> Void
    let onOpenToggle: () -> Void
    let onTaskToggle: (RoomTask) -> Void
    let onVIPToggle: () -> Void
    let onScheduleToggle: () -> Void
    @State private var swipeFeedbackActive = false

    var body: some View {
        VStack(spacing: 0) {
            tileBody

            if isActionMenuExpanded {
                SummaryRoomActionMenu(
                    room: room,
                    onNotes: onOpenNotes,
                    onVoice: onOpenVoice,
                    onMedia: onOpenMedia,
                    onVIPToggle: onVIPToggle,
                    onScheduleToggle: onScheduleToggle
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.smooth(duration: 0.26), value: isActionMenuExpanded)
        .simultaneousGesture(actionMenuDragGesture)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Room \(room.id)")
    }

    private var tileBody: some View {
        HStack(spacing: geometry.taskSpacing) {
            HoldActionTarget(
                enabled: true,
                useLongPress: taskControlsUseLongPress,
                semanticLabel: "Room \(room.id)",
                onActivate: activateOpenToggle
            ) {
                Text(room.id)
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(OceanKeyTheme.roomForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach(RoomTask.allCases) { taskButton($0) }
        }
        .padding(.leading, geometry.tileLeadingPadding)
        .padding(.trailing, geometry.tileTrailingPadding)
        .frame(height: geometry.tileHeight)
        .foregroundStyle(OceanKeyTheme.roomForeground)
        .background(cellBackground)
        .clipShape(tileShape)
        .overlay(alignment: .topTrailing) {
            if room.isVIP {
                VIPPulseOverlay()
                    .clipShape(tileShape)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if let scheduleLabel = room.scheduleLabel {
                Text(scheduleLabel)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.72))
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 8,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: isActionMenuExpanded ? 0 : 13,
                            topTrailingRadius: 0,
                            style: .continuous
                        )
                    )
            }
        }
    }

    private func taskButton(_ task: RoomTask) -> some View {
        HoldActionTarget(
            enabled: room.opened,
            useLongPress: taskControlsUseLongPress,
            semanticLabel: "Room \(room.id) task \(task.rawValue)",
            onActivate: { activateTask(task) }
        ) {
            Text(task.rawValue)
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(taskColor(task))
                .frame(width: 50, height: 54)
        }
    }

    private var actionMenuDragGesture: some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onChanged { value in
                guard isHorizontalActionSwipe(value) else { return }
                guard value.translation.width > 18 else { return }
                if !swipeFeedbackActive {
                    swipeFeedbackActive = true
                    feedback.holdStart()
                }
            }
            .onEnded { value in
                defer { swipeFeedbackActive = false }
                guard isHorizontalActionSwipe(value) else { return }
                if value.translation.width > 56 {
                    feedback.confirm()
                    onActionMenuToggle()
                }
            }
    }

    private func isHorizontalActionSwipe(_ value: DragGesture.Value) -> Bool {
        abs(value.translation.width) > abs(value.translation.height) * 1.35
    }

    private func activateOpenToggle() {
        if !taskControlsUseLongPress {
            feedback.confirm()
        }
        onOpenToggle()
    }

    private func activateTask(_ task: RoomTask) {
        if !taskControlsUseLongPress {
            if room.completedTasks.contains(task) {
                feedback.deselect()
            } else {
                feedback.select()
            }
        }
        onTaskToggle(task)
    }

    private var cellBackground: some View {
        tileShape
            .fill(OceanKeyTheme.fill(for: room.status))
            .shadow(color: .black.opacity(geometry.tileShadowOpacity), radius: 5, x: 0, y: 4)
    }

    private var tileShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: geometry.tileCornerRadius,
            bottomLeadingRadius: isActionMenuExpanded ? 0 : geometry.tileCornerRadius,
            bottomTrailingRadius: isActionMenuExpanded ? 0 : geometry.tileCornerRadius,
            topTrailingRadius: geometry.tileCornerRadius,
            style: .continuous
        )
    }

    private func taskColor(_ task: RoomTask) -> Color {
        guard room.opened else { return OceanKeyTheme.roomForeground.opacity(0.25) }
        return room.completedTasks.contains(task) ? OceanKeyTheme.roomForeground : OceanKeyTheme.roomForeground.opacity(0.32)
    }
}

private extension RoomCell {
    var scheduleLabel: String? {
        guard let scheduledTime else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: scheduledTime)
    }
}

#Preview {
    @Previewable @State var room = WorkSessionStore.preview().carts[0].rooms[0]
    return RoomCellView(
        room: $room,
        geometry: .roomy,
        taskControlsUseLongPress: true,
        isActionMenuExpanded: true,
        onActionMenuToggle: {},
        onOpenNotes: {},
        onOpenVoice: {},
        onOpenMedia: {},
        onOpenToggle: {},
        onTaskToggle: { _ in },
        onVIPToggle: {},
        onScheduleToggle: {}
    )
        .padding()
        .background(OceanKeyTheme.background)
}
