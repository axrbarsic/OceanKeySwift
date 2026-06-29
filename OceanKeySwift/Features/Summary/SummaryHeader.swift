import SwiftUI

struct SummaryHeader: View {
    let counts: SummaryCounts
    @Binding var personalCartMarkers: PersonalCartMarkers
    let personalCartMarkerInputMode: PersonalCartMarkerInputMode
    let onOpenSettings: () -> Void
    let onOpenSelection: () -> Void
    @Environment(\.interactionFeedback) private var feedback
    @Environment(\.settingsOpenRequiresLongPress) private var settingsOpenRequiresLongPress
    @Environment(\.zeroScreenReturnAction) private var returnToZeroScreen
    @State private var selectionPuzzleProgress: CGFloat = 0
    @State private var zeroScreenPuzzleProgress: CGFloat = 0
    @State private var zeroScreenReturnArmed = false
    @State private var zeroScreenReturnFeedbackStarted = false

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 8) {
                softButton(
                    systemName: "line.3.horizontal",
                    headerWidth: proxy.size.width,
                    action: onOpenSettings
                )
                    .opacity(settingsButtonOpacity)

                PersonalCartMarkerStrip(
                    markers: personalCartMarkers,
                    inputMode: personalCartMarkerInputMode,
                    onStep: stepPersonalCartMarker,
                    onPreviewFloor: previewPersonalCartMarkerFloor,
                    onSetFloor: setPersonalCartMarkerFloor
                )

                Spacer(minLength: 6)

                HStack(spacing: 12) {
                    Text("\(counts.total)").foregroundStyle(OceanKeyTheme.pending)
                    Text("\(counts.completed)").foregroundStyle(OceanKeyTheme.ready)
                    Text("\(counts.remaining)").foregroundStyle(Color(hex: 0xFF4A4A))
                }
                .font(.system(size: 22, weight: .black, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .layoutPriority(1)

                Spacer(minLength: 94)
            }
            .padding(.leading, 18)
            .padding(.trailing, 10)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay {
                SummarySelectionPuzzleHandle(
                    progress: $selectionPuzzleProgress,
                    onComplete: onOpenSelection
                )
            }
            .overlay {
                if returnToZeroScreen != nil {
                    SummaryZeroScreenPuzzleHandle(
                        progress: $zeroScreenPuzzleProgress
                    )
                    .allowsHitTesting(false)
                }
            }
        }
        .frame(height: 48)
    }

    private var settingsButtonOpacity: CGFloat {
        CGFloat(1) - min(max(selectionPuzzleProgress, zeroScreenPuzzleProgress) * CGFloat(1.65), CGFloat(1))
    }

    private func softButton(
        systemName: String,
        headerWidth: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        HoldActionTarget(
            enabled: true,
            useLongPress: settingsOpenRequiresLongPress,
            semanticLabel: "Открыть настройки",
            onActivate: action
        ) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .black))
                .frame(width: 48, height: 48)
                .foregroundStyle(OceanKeyTheme.secondaryText)
                .background(.black.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(OceanKeyTheme.accent.opacity(0.16), lineWidth: 1)
                }
        }
        .simultaneousGesture(zeroScreenReturnGesture(headerWidth: headerWidth))
    }

    private func zeroScreenReturnGesture(headerWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onChanged { value in
                guard returnToZeroScreen != nil else { return }
                let metrics = SummaryZeroScreenReturnMetrics(width: headerWidth)
                let next = min(max(value.translation.width, 0), metrics.travel * 1.08)
                guard next > 0 || zeroScreenPuzzleProgress > 0 else { return }
                if next > 2, !zeroScreenReturnFeedbackStarted {
                    zeroScreenReturnFeedbackStarted = true
                    feedback.holdStart()
                }
                let nextArmed = next >= metrics.travel
                if nextArmed, !zeroScreenReturnArmed {
                    feedback.holdCommit()
                } else if !nextArmed, next > metrics.travel * 0.82, !zeroScreenReturnArmed {
                    feedback.holdWarning()
                }
                zeroScreenPuzzleProgress = metrics.progress(for: next)
                zeroScreenReturnArmed = nextArmed
            }
            .onEnded { _ in
                guard zeroScreenReturnArmed else {
                    resetZeroScreenReturn()
                    return
                }
                zeroScreenPuzzleProgress = 1
                feedback.confirm()
                returnToZeroScreen?()
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(160))
                    resetZeroScreenReturn()
                }
            }
    }

    private func resetZeroScreenReturn() {
        zeroScreenPuzzleProgress = 0
        zeroScreenReturnArmed = false
        zeroScreenReturnFeedbackStarted = false
    }

    private func stepPersonalCartMarker(_ slot: PersonalCartMarkerSlot, direction: PersonalCartMarkerStepDirection) {
        let nextFloor = personalCartMarkers.steppedFloor(for: slot, direction: direction)
        personalCartMarkers = personalCartMarkers.settingFloor(nextFloor, for: slot)
        feedback.detent()
    }

    private func previewPersonalCartMarkerFloor(_ slot: PersonalCartMarkerSlot, floor: Int?) {
        feedback.detent()
    }

    private func setPersonalCartMarkerFloor(_ slot: PersonalCartMarkerSlot, floor: Int?) {
        personalCartMarkers = personalCartMarkers.settingFloor(floor, for: slot)
        feedback.confirm()
    }
}

private struct SummaryZeroScreenReturnMetrics {
    let width: CGFloat

    private let horizontalPadding: CGFloat = 18
    private let settingsButtonSize: CGFloat = 48
    private let startZoneWidth: CGFloat = 86

    var startCenterX: CGFloat { horizontalPadding + settingsButtonSize * 0.5 }
    var targetCenterX: CGFloat { width - horizontalPadding - startZoneWidth * 0.5 }
    var travel: CGFloat { max(targetCenterX - startCenterX, 1) }

    func progress(for drag: CGFloat) -> CGFloat {
        min(max(drag / travel, 0), 1)
    }
}

#Preview {
    @Previewable @State var markers = PersonalCartMarkers(
        aYellowFloor: 3,
        aGrayFloor: nil,
        bYellowFloor: 5,
        bGrayFloor: 2
    )
    SummaryHeader(
        counts: SummaryCounts(total: 10, completed: 10, remaining: 0),
        personalCartMarkers: $markers,
        personalCartMarkerInputMode: .swipeDetents,
        onOpenSettings: {},
        onOpenSelection: {}
    )
        .background(OceanKeyTheme.background)
}
