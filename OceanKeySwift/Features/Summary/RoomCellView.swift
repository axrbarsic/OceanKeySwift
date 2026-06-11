import SwiftUI
import UIKit

struct RoomCellView: View {
    @Environment(\.interactionFeedback) private var feedback
    @Environment(\.experimentalCellPhysicsEnabled) private var experimentalCellPhysicsEnabled
    @Environment(\.experimentalCellSpringIntensity) private var experimentalCellSpringIntensity
    @Environment(\.experimentalCellSpringSpeed) private var experimentalCellSpringSpeed
    @Environment(\.experimentalVIPJellyEnabled) private var experimentalVIPJellyEnabled
    @Environment(\.experimentalVIPJellySpeed) private var experimentalVIPJellySpeed

    @Binding var room: RoomCell
    let geometry: RoomCellGeometry
    let taskControlsUseLongPress: Bool
    let statusPaletteSaturation: Double
    let isActionMenuExpanded: Bool
    let onActionMenuToggle: () -> Void
    let onOpenMultimodalNote: () -> Void
    let onOpenToggle: () -> Void
    let onTaskToggle: (RoomTask) -> Void
    let onVIPToggle: () -> Void
    let onScheduleToggle: () -> Void
    @State private var swipeFeedbackActive = false
    @State private var swipeDX: CGFloat = 0
    @State private var swipeDY: CGFloat = 0
    @State private var swipeDirection = 0
    @State private var swipeArmed = false
    @State private var swipeProgress: CGFloat = 0
    @State private var tileWidth: CGFloat = 0
    @State private var physicsPulse = false

    var body: some View {
        VStack(spacing: 0) {
            tileBody
                .contentShape(Rectangle())
                .highPriorityGesture(closeExpandedMenuTapGesture, including: .gesture)
                .simultaneousGesture(actionMenuDragGesture, including: .gesture)

            if isActionMenuExpanded {
                SummaryRoomActionMenu(
                    room: room,
                    onMultimodalNote: onOpenMultimodalNote,
                    onVIPToggle: onVIPToggle,
                    onScheduleToggle: onScheduleToggle
                )
                .transition(.roomActionMenuLamp)
            }
        }
        .animation(.smooth(duration: 1.15), value: isActionMenuExpanded)
        .onChange(of: room.status) { _, _ in
            triggerPhysicsPulse()
        }
        .onChange(of: room.completedTasks) { _, _ in
            triggerPhysicsPulse()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Room \(room.id)")
    }

    private var tileBody: some View {
        Group {
            if vipJellyActive {
                TimelineView(.animation(minimumInterval: 1.0 / 120.0)) { timeline in
                    tileBodyContent(vipJellyTime: timeline.date.timeIntervalSinceReferenceDate)
                }
            } else {
                tileBodyContent(vipJellyTime: nil)
            }
        }
    }

    private func tileBodyContent(vipJellyTime: TimeInterval?) -> some View {
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
        .background(cellFill)
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
        .overlay(alignment: .topTrailing) {
            RoomMediaIndicator(room: room)
                .padding(.top, 7)
                .padding(.trailing, 10)
                .allowsHitTesting(false)
        }
        .overlay {
            if swipeProgress > 0 {
                RoomActionPuzzlePullOverlay(progress: swipeProgress)
                    .allowsHitTesting(false)
            }
        }
        .roomCellStaticClip(enabled: !vipJellyActive, shape: tileShape)
        .vipJellyUnifiedLayer(
            enabled: vipJellyActive,
            time: vipJellyTime,
            speed: experimentalVIPJellySpeed,
            seed: vipJellySeed,
            cornerRadius: geometry.tileCornerRadius
        )
        .vipJellyShapeMask(
            enabled: vipJellyActive,
            time: vipJellyTime,
            speed: experimentalVIPJellySpeed,
            seed: vipJellySeed,
            cornerRadius: geometry.tileCornerRadius,
            isMenuExpanded: isActionMenuExpanded
        )
        .shadow(color: .black.opacity(geometry.tileShadowOpacity), radius: 5, x: 0, y: 4)
        .scaleEffect(
            x: experimentalCellPhysicsEnabled && physicsPulse ? 1 + 0.09 * experimentalCellSpringIntensity : 1,
            y: experimentalCellPhysicsEnabled && physicsPulse ? 1 - 0.12 * experimentalCellSpringIntensity : 1
        )
        .offset(y: experimentalCellPhysicsEnabled && physicsPulse ? -7 * experimentalCellSpringIntensity : 0)
        .offset(x: swipeProgress * 10)
        .rotation3DEffect(
            .degrees(experimentalCellPhysicsEnabled && physicsPulse ? 7.5 * experimentalCellSpringIntensity : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0),
            perspective: 0.72
        )
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        tileWidth = proxy.size.width
                    }
                    .onChange(of: proxy.size.width) { _, width in
                        tileWidth = width
                    }
            }
        }
        .animation(
            experimentalCellPhysicsEnabled
                ? .interpolatingSpring(
                    stiffness: 180 + 220 * experimentalCellSpringSpeed,
                    damping: max(5, 15 - 7 * experimentalCellSpringIntensity)
                )
                : .default,
            value: physicsPulse
        )
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
        DragGesture(minimumDistance: 26, coordinateSpace: .local)
            .onChanged { value in
                updateActionMenuDrag(value)
            }
            .onEnded { value in
                finishActionMenuDrag(value)
            }
    }

    private var closeExpandedMenuTapGesture: some Gesture {
        TapGesture()
            .onEnded {
                guard isActionMenuExpanded else { return }
                feedback.deselect()
                onActionMenuToggle()
            }
    }

    private func updateActionMenuDrag(_ value: DragGesture.Value) {
        swipeDX = value.translation.width
        swipeDY = value.translation.height

        let absX = abs(swipeDX)
        let absY = abs(swipeDY)
        if absY > 10, absY > absX {
            resetActionMenuDrag()
            return
        }

        if swipeDirection == 0 {
            guard absX >= 36, absX >= absY * 2.6 else { return }
            guard swipeDX > 0 else {
                resetActionMenuDrag()
                return
            }
            swipeDirection = 1
            if !swipeFeedbackActive {
                swipeFeedbackActive = true
                feedback.holdStart()
            }
        }

        swipeProgress = SummarySwipeCommitPolicy.roomActionMenuProgress(
            translation: max(swipeDX, 0),
            cellWidth: actionMenuCellWidth
        )
        let armed = swipeProgress >= 1
        if armed, !swipeArmed {
            feedback.holdCommit()
        } else if !armed, swipeProgress > 0.86, !swipeArmed {
            feedback.holdWarning()
        }
        swipeArmed = armed
    }

    private func finishActionMenuDrag(_ value: DragGesture.Value) {
        defer { resetActionMenuDrag() }
        let armed = swipeArmed || SummarySwipeCommitPolicy.roomActionMenuArmed(
            translation: value.translation.width,
            predictedTranslation: value.predictedEndTranslation.width,
            cellWidth: actionMenuCellWidth
        )
        guard swipeDirection > 0, armed else { return }
        feedback.confirm()
        onActionMenuToggle()
    }

    private func resetActionMenuDrag() {
        swipeFeedbackActive = false
        swipeDX = 0
        swipeDY = 0
        swipeDirection = 0
        swipeArmed = false
        withAnimation(.smooth(duration: 0.18)) {
            swipeProgress = 0
        }
    }

    private var actionMenuSwipeThreshold: CGFloat {
        SummarySwipeCommitPolicy.roomActionMenuThreshold(cellWidth: actionMenuCellWidth)
    }

    private var actionMenuCellWidth: CGFloat {
        tileWidth > 0 ? tileWidth : UIScreen.main.bounds.width - 32
    }

    private func triggerPhysicsPulse() {
        guard experimentalCellPhysicsEnabled else { return }
        physicsPulse = true
        Task { @MainActor in
            let duration = max(110, Int(280 / experimentalCellSpringSpeed))
            try? await Task.sleep(for: .milliseconds(duration))
            physicsPulse = false
        }
    }

    private func activateOpenToggle() {
        if !taskControlsUseLongPress {
            feedback.confirm()
        }
        triggerPhysicsPulse()
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
        triggerPhysicsPulse()
        onTaskToggle(task)
    }

    // VIP source must stay rectangular here. The shared jelly mask below creates
    // the animated silhouette; a pre-clip would kill the moving contour.
    @ViewBuilder
    private var cellFill: some View {
        let fill = OceanKeyTheme.fill(for: room.status, saturation: statusPaletteSaturation)
        if vipJellyActive {
            Rectangle().fill(fill)
        } else {
            tileShape.fill(fill)
        }
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

    private var vipJellyActive: Bool {
        room.isVIP && experimentalVIPJellyEnabled
    }

    private var vipJellySeed: Double {
        Double(abs(room.id.hashValue % 10_000)) / 10_000
    }
}

private extension View {
    /// Единый монолитный warp: ячейка уже растеризована (`compositingGroup`)
    /// вместе с заливкой, рамкой, номером, S/L/B и бейджами, и ВЕСЬ слой
    /// деформируется одним Metal-полем. Контур и содержимое по построению
    /// двигаются вместе — никакой отдельной кляксы и имитаций per-label.
    @ViewBuilder
    func vipJellyUnifiedLayer(
        enabled: Bool,
        time: TimeInterval?,
        speed: Double,
        seed: Double,
        cornerRadius: CGFloat
    ) -> some View {
        if enabled, let time {
            self
                .compositingGroup()
                .visualEffect { content, proxy in
                    let amplitude = min(max(proxy.size.height * 0.24, 10), 20)
                    return content.layerEffect(
                        ShaderLibrary.vipJellyUnifiedLayer(
                            .float(Float(time)),
                            .float(Float(speed)),
                            .float(Float(seed)),
                            .float2(Float(proxy.size.width), Float(proxy.size.height)),
                            .float(Float(amplitude)),
                            .float(Float(cornerRadius))
                        ),
                        maxSampleOffset: CGSize(
                            width: amplitude * 1.1,
                            height: amplitude * 1.45
                        )
                    )
                }
        } else {
            self
        }
    }

    @ViewBuilder
    func roomCellStaticClip(enabled: Bool, shape: UnevenRoundedRectangle) -> some View {
        if enabled {
            self.clipShape(shape)
        } else {
            self
        }
    }

    @ViewBuilder
    func vipJellyShapeMask(
        enabled: Bool,
        time: TimeInterval?,
        speed: Double,
        seed: Double,
        cornerRadius: CGFloat,
        isMenuExpanded: Bool
    ) -> some View {
        if enabled, let time {
            self.mask {
                VIPJellyCellShape(
                    time: time,
                    speed: speed,
                    seed: seed,
                    cornerRadius: cornerRadius,
                    isMenuExpanded: isMenuExpanded
                )
                .fill(.black)
            }
        } else {
            self
        }
    }
}

private struct VIPJellyCellShape: Shape {
    let time: TimeInterval
    let speed: Double
    let seed: Double
    let cornerRadius: CGFloat
    let isMenuExpanded: Bool

    func path(in rect: CGRect) -> Path {
        let normalizedSpeed = min(max(speed, 0.2), 2.5)
        let t = time * normalizedSpeed
        let amplitude = min(rect.height * 0.22, 18)
        let left = rect.minX
        let right = rect.maxX
        let top = rect.minY
        let bottom = rect.maxY
        let radius = min(cornerRadius, rect.height * 0.46, rect.width * 0.12)
        let bottomRadius = isMenuExpanded ? 0 : radius

        var path = Path()
        path.move(to: CGPoint(x: left + radius, y: top + jellyOffset(edge: 0, unit: 0, time: t, amplitude: amplitude)))
        addHorizontalEdge(to: &path, y: top, fromX: left + radius, toX: right - radius, edge: 0, time: t, amplitude: amplitude)
        path.addQuadCurve(
            to: CGPoint(x: right, y: top + radius),
            control: CGPoint(x: right + jellyOffset(edge: 4, unit: 0.25, time: t, amplitude: amplitude * 0.55), y: top)
        )
        addVerticalEdge(to: &path, x: right, fromY: top + radius, toY: bottom - bottomRadius, edge: 1, time: t, amplitude: amplitude)
        if bottomRadius > 0 {
            path.addQuadCurve(
                to: CGPoint(x: right - bottomRadius, y: bottom),
                control: CGPoint(x: right, y: bottom + jellyOffset(edge: 5, unit: 0.75, time: t, amplitude: amplitude * 0.55))
            )
        }
        addHorizontalEdge(to: &path, y: bottom, fromX: right - bottomRadius, toX: left + bottomRadius, edge: 2, time: t, amplitude: amplitude)
        if bottomRadius > 0 {
            path.addQuadCurve(
                to: CGPoint(x: left, y: bottom - bottomRadius),
                control: CGPoint(x: left + jellyOffset(edge: 6, unit: 0.35, time: t, amplitude: amplitude * 0.55), y: bottom)
            )
        }
        addVerticalEdge(to: &path, x: left, fromY: bottom - bottomRadius, toY: top + radius, edge: 3, time: t, amplitude: amplitude)
        path.addQuadCurve(
            to: CGPoint(x: left + radius, y: top),
            control: CGPoint(x: left, y: top + jellyOffset(edge: 7, unit: 0.9, time: t, amplitude: amplitude * 0.55))
        )
        path.closeSubpath()
        return path
    }

    private func addHorizontalEdge(
        to path: inout Path,
        y: CGFloat,
        fromX: CGFloat,
        toX: CGFloat,
        edge: Int,
        time: Double,
        amplitude: CGFloat
    ) {
        let steps = 28
        var points: [CGPoint] = []
        points.reserveCapacity(steps + 1)
        for index in 0...steps {
            let unit = Double(index) / Double(steps)
            let x = fromX + (toX - fromX) * CGFloat(unit)
            points.append(CGPoint(x: x, y: y + jellyOffset(edge: edge, unit: unit, time: time, amplitude: amplitude)))
        }
        addSmoothEdge(to: &path, points: points)
    }

    private func addVerticalEdge(
        to path: inout Path,
        x: CGFloat,
        fromY: CGFloat,
        toY: CGFloat,
        edge: Int,
        time: Double,
        amplitude: CGFloat
    ) {
        let steps = 12
        var points: [CGPoint] = []
        points.reserveCapacity(steps + 1)
        for index in 0...steps {
            let unit = Double(index) / Double(steps)
            let y = fromY + (toY - fromY) * CGFloat(unit)
            points.append(CGPoint(x: x + jellyOffset(edge: edge, unit: unit, time: time, amplitude: amplitude * 0.55), y: y))
        }
        addSmoothEdge(to: &path, points: points)
    }

    private func addSmoothEdge(to path: inout Path, points: [CGPoint]) {
        guard points.count > 1 else { return }
        for index in 0..<(points.count - 1) {
            let previous = points[max(index - 1, 0)]
            let current = points[index]
            let next = points[index + 1]
            let afterNext = points[min(index + 2, points.count - 1)]
            let control1 = CGPoint(
                x: current.x + (next.x - previous.x) / 6,
                y: current.y + (next.y - previous.y) / 6
            )
            let control2 = CGPoint(
                x: next.x - (afterNext.x - current.x) / 6,
                y: next.y - (afterNext.y - current.y) / 6
            )
            path.addCurve(to: next, control1: control1, control2: control2)
        }
    }

    private func jellyOffset(edge: Int, unit: Double, time: Double, amplitude: CGFloat) -> CGFloat {
        let edgeSeed = seed * 19.37 + Double(edge) * 0.731
        let slow = sin((unit * (1.7 + edgeSeed.truncatingRemainder(dividingBy: 1.9)) + time * (0.31 + edgeSeed * 0.017) + edgeSeed) * .pi * 2)
        let medium = sin((unit * (3.1 + edgeSeed.truncatingRemainder(dividingBy: 2.4)) - time * (0.47 + seed * 0.09) + edgeSeed * 1.41) * .pi * 2)
        let fast = sin((unit * (4.6 + seed * 1.7) + time * (0.61 + Double(edge) * 0.017) + edgeSeed * 2.17) * .pi * 2)
        let drift = sin((time * 0.113 + seed * 8.0 + Double(edge)) * .pi * 2)
        let value = slow * 0.52 + medium * 0.31 + fast * 0.11 + drift * 0.06
        return CGFloat(value) * amplitude
    }
}

private struct RoomMediaIndicator: View {
    let room: RoomCell

    var body: some View {
        if let primaryIcon = room.primaryAttachmentIndicatorIcon {
            HStack(spacing: 4) {
                Image(systemName: primaryIcon)
                    .font(.system(size: 14, weight: .black))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, OceanKeyTheme.accent)

                if room.attachmentIndicatorCount > 1 {
                    Text("\(room.attachmentIndicatorCount)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, room.attachmentIndicatorCount > 1 ? 7 : 6)
            .frame(height: 26)
            .background(.black.opacity(0.26), in: Capsule())
            .background(.ultraThinMaterial.opacity(0.72), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.36), lineWidth: 0.8)
            }
            .foregroundStyle(.white.opacity(0.96))
            .shadow(color: .black.opacity(0.36), radius: 4, x: 0, y: 1)
        }
    }
}

private struct RoomActionPuzzlePullOverlay: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let sinkSize = min(max(proxy.size.height * 0.52, 34), 48)
            let normalized = min(max(progress, 0), 1)
            let startCenterX = sinkSize * 0.5 + 14
            let targetCenterX = width - sinkSize * 0.5 - 16
            let pieceCenterX = startCenterX + (targetCenterX - startCenterX) * normalized

            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: [
                        .white.opacity(0.02),
                        OceanKeyTheme.accent.opacity(0.08 + normalized * 0.15),
                        .white.opacity(0.04 + normalized * 0.16)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .blendMode(.screen)

                PuzzleSocket(progress: normalized)
                    .frame(width: sinkSize, height: sinkSize)
                    .position(x: targetCenterX, y: proxy.size.height * 0.5)

                PuzzlePiece(progress: normalized, systemName: "puzzlepiece.fill")
                    .frame(width: sinkSize, height: sinkSize)
                    .position(x: pieceCenterX, y: proxy.size.height * 0.5)
            }
        }
    }
}

// Кэш формата: body VIP-ячейки пересчитывается каждый кадр (TimelineView),
// создавать DateFormatter на каждый проход — лишние аллокации.
private let roomScheduleLabelFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "h:mm a"
    return formatter
}()

private extension RoomCell {
    var scheduleLabel: String? {
        guard let scheduledTime else { return nil }
        return roomScheduleLabelFormatter.string(from: scheduledTime)
    }

    var primaryAttachmentIndicatorIcon: String? {
        guard let attachments = mediaAttachments, !attachments.isEmpty else { return nil }
        if attachments.contains(where: { $0.kind == .audio }) { return "waveform.circle.fill" }
        if attachments.contains(where: { $0.kind == .video }) { return "play.rectangle.fill" }
        if attachments.contains(where: { $0.kind == .photo }) { return "photo.circle.fill" }
        return "paperclip.circle.fill"
    }

    var attachmentIndicatorCount: Int {
        mediaAttachments?.count ?? 0
    }
}

#Preview {
    @Previewable @State var room = WorkSessionStore.preview().carts[0].rooms[0]
    return RoomCellView(
        room: $room,
        geometry: .roomy,
        taskControlsUseLongPress: true,
        statusPaletteSaturation: 1,
        isActionMenuExpanded: true,
        onActionMenuToggle: {},
        onOpenMultimodalNote: {},
        onOpenToggle: {},
        onTaskToggle: { _ in },
        onVIPToggle: {},
        onScheduleToggle: {}
    )
        .padding()
        .background(OceanKeyTheme.background)
}
