import SwiftUI

struct PersonalCartMarkerStrip: View {
    let markers: PersonalCartMarkers
    let inputMode: PersonalCartMarkerInputMode
    let onStep: (PersonalCartMarkerSlot, PersonalCartMarkerStepDirection) -> Void
    let onPreviewFloor: (PersonalCartMarkerSlot, Int?) -> Void
    let onSetFloor: (PersonalCartMarkerSlot, Int?) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(PersonalCartMarkers.visibleSlots) { slot in
                PersonalCartMarkerButton(
                    slot: slot,
                    floor: markers.floor(for: slot),
                    inputMode: inputMode,
                    onStep: { direction in onStep(slot, direction) },
                    onPreviewFloor: { floor in onPreviewFloor(slot, floor) },
                    onSetFloor: { floor in onSetFloor(slot, floor) }
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Метки персональных тележек")
    }
}

private struct PersonalCartMarkerButton: View {
    let slot: PersonalCartMarkerSlot
    let floor: Int?
    let inputMode: PersonalCartMarkerInputMode
    let onStep: (PersonalCartMarkerStepDirection) -> Void
    let onPreviewFloor: (Int?) -> Void
    let onSetFloor: (Int?) -> Void
    @State private var consumedDragSteps = 0
    @State private var isExpanded = false
    @State private var isMenuPresented = false
    @State private var highlightedFloor: Int?
    @State private var collapseTask: Task<Void, Never>?

    private let stepHeight: CGFloat = 18
    private let pressMenuTopY: CGFloat = -148
    private let pressMenuItemHeight: CGFloat = 28

    var body: some View {
        switch inputMode {
        case .swipeDetents:
            swipeBody
        case .pressMenu:
            pressMenuBody
        }
    }

    private var swipeBody: some View {
        markerBody
            .gesture(stepGesture)
            .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.68), value: isExpanded)
            .accessibilityLabel(accessibilityText)
            .accessibilityHint("Веди вверх или вниз, чтобы поменять этаж")
            .accessibilityAdjustableAction(adjustFloor)
            .onDisappear {
                collapseTask?.cancel()
            }
    }

    private var pressMenuBody: some View {
        markerBody
            .overlay(alignment: .top) {
                if isMenuPresented {
                    pressFloorMenu
                        .offset(y: pressMenuTopY)
                        .transition(.scale(scale: 0.86, anchor: .bottom).combined(with: .opacity))
                }
            }
            .gesture(pressMenuGesture)
            .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.72), value: isExpanded)
            .animation(.easeOut(duration: 0.16), value: isMenuPresented)
            .accessibilityLabel(accessibilityText)
            .accessibilityHint("Удерживай, веди по списку этажей и отпускай")
            .accessibilityAdjustableAction(adjustFloor)
            .onDisappear {
                collapseTask?.cancel()
            }
    }

    private var markerBody: some View {
        Text(label)
            .font(.system(size: 17, weight: .black, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .foregroundStyle(foreground)
            .frame(width: 34, height: 26)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(.white.opacity(floor == nil ? 0.22 : 0.42), lineWidth: isExpanded ? 1.6 : 1)
            }
            .overlay(alignment: .top, content: detentHighlight)
            .shadow(color: fill.opacity(isExpanded ? 0.50 : 0.28), radius: isExpanded ? 14 : 4, x: 0, y: isExpanded ? 7 : 2)
            .scaleEffect(isExpanded ? 1.88 : 1.0)
            .offset(y: isExpanded ? -22 : 0)
            .zIndex(isExpanded ? 10 : 0)
            .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    @ViewBuilder
    private func detentHighlight() -> some View {
        if isExpanded {
            Capsule()
                .fill(.white.opacity(0.34))
                .frame(width: 14, height: 2)
                .offset(y: 3)
        }
    }

    private func adjustFloor(_ direction: AccessibilityAdjustmentDirection) {
        switch direction {
        case .increment:
            onStep(.up)
            expandForSelection()
            scheduleCollapse()
        case .decrement:
            onStep(.down)
            expandForSelection()
            scheduleCollapse()
        default:
            break
        }
    }

    private var pressFloorMenu: some View {
        VStack(spacing: 0) {
            ForEach(Array(pressMenuFloors.enumerated()), id: \.offset) { _, option in
                Text(label(for: option))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(option == highlightedFloor ? activeMenuForeground : .white.opacity(0.82))
                    .frame(width: 48, height: pressMenuItemHeight)
                    .background(option == highlightedFloor ? fill.opacity(0.92) : Color.white.opacity(0.07))
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.white.opacity(0.08))
                            .frame(height: 1)
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(fill.opacity(0.72), lineWidth: 1.2)
        }
        .shadow(color: .black.opacity(0.34), radius: 14, x: 0, y: 8)
        .zIndex(20)
    }

    private var stepGesture: some Gesture {
        DragGesture(minimumDistance: 7, coordinateSpace: .local)
            .onChanged { value in
                expandForSelection()
                handleDrag(value)
            }
            .onEnded { _ in
                consumedDragSteps = 0
                scheduleCollapse()
            }
    }

    private var pressMenuGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.26, maximumDistance: 18)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .onChanged { value in
                switch value {
                case .first(true):
                    presentMenu()
                case .second(true, let drag):
                    presentMenu()
                    if let drag {
                        updateMenuSelection(at: drag.location)
                    }
                default:
                    break
                }
            }
            .onEnded { _ in
                if isMenuPresented {
                    onSetFloor(highlightedFloor)
                }
                dismissMenu()
            }
    }

    private func handleDrag(_ value: DragGesture.Value) {
        guard abs(value.translation.height) >= abs(value.translation.width) else { return }
        let rawSteps = Int((-value.translation.height / stepHeight).rounded(.towardZero))
        let delta = rawSteps - consumedDragSteps
        guard delta != 0 else { return }
        let direction: PersonalCartMarkerStepDirection = delta > 0 ? .up : .down
        for _ in 0..<abs(delta) {
            onStep(direction)
        }
        consumedDragSteps = rawSteps
    }

    private func presentMenu() {
        collapseTask?.cancel()
        collapseTask = nil
        if !isExpanded {
            isExpanded = true
        }
        if !isMenuPresented {
            highlightedFloor = floor
            isMenuPresented = true
        }
    }

    private func updateMenuSelection(at location: CGPoint) {
        guard let option = menuOption(at: location), option != highlightedFloor else { return }
        highlightedFloor = option
        onPreviewFloor(option)
    }

    private func dismissMenu() {
        isMenuPresented = false
        highlightedFloor = nil
        scheduleCollapse()
    }

    private func menuOption(at location: CGPoint) -> Int?? {
        let rawIndex = Int(((location.y - pressMenuTopY) / pressMenuItemHeight).rounded(.down))
        guard pressMenuFloors.indices.contains(rawIndex) else { return nil }
        return pressMenuFloors[rawIndex]
    }

    private func expandForSelection() {
        collapseTask?.cancel()
        collapseTask = nil
        if !isExpanded {
            isExpanded = true
        }
    }

    private func scheduleCollapse() {
        collapseTask?.cancel()
        collapseTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.15))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 1.35)) {
                isExpanded = false
            }
        }
    }

    private var label: String {
        if let floor {
            "\(floor)"
        } else {
            "-"
        }
    }

    private var accessibilityText: String {
        if let floor {
            "\(slot.title), этаж \(floor)"
        } else {
            "\(slot.title), этаж не выбран"
        }
    }

    private var fill: Color {
        switch slot.tone {
        case .yellow:
            Color(hex: 0xFFD83D)
        case .gray:
            Color(hex: 0x9DA3A6)
        }
    }

    private var foreground: Color {
        switch slot.tone {
        case .yellow:
            Color.black.opacity(0.88)
        case .gray:
            Color.white
        }
    }

    private var activeMenuForeground: Color {
        switch slot.tone {
        case .yellow:
            Color.black.opacity(0.88)
        case .gray:
            Color.white
        }
    }

    private var pressMenuFloors: [Int?] {
        [nil] + PersonalCartMarkers.allowedFloors
    }

    private func label(for floor: Int?) -> String {
        floor.map(String.init) ?? "-"
    }
}

#Preview {
    PersonalCartMarkerStrip(
        markers: PersonalCartMarkers(
            aYellowFloor: 3,
            aGrayFloor: nil,
            bYellowFloor: 5,
            bGrayFloor: 2
        ),
        inputMode: .pressMenu,
        onStep: { _, _ in },
        onPreviewFloor: { _, _ in },
        onSetFloor: { _, _ in }
    )
    .padding()
    .background(OceanKeyTheme.background)
}
