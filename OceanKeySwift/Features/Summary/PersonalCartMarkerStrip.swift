import SwiftUI

struct PersonalCartMarkerStrip: View {
    let markers: PersonalCartMarkers
    let onTap: (PersonalCartMarkerSlot) -> Void
    let onStep: (PersonalCartMarkerSlot, PersonalCartMarkerStepDirection) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(PersonalCartMarkers.visibleSlots) { slot in
                PersonalCartMarkerButton(
                    slot: slot,
                    floor: markers.floor(for: slot),
                    onTap: { onTap(slot) },
                    onStep: { direction in onStep(slot, direction) }
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
    let onTap: () -> Void
    let onStep: (PersonalCartMarkerStepDirection) -> Void
    @State private var consumedDragSteps = 0
    @State private var didStepDuringGesture = false

    private let stepHeight: CGFloat = 18

    var body: some View {
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
                    .stroke(.white.opacity(floor == nil ? 0.22 : 0.34), lineWidth: 1)
            }
            .shadow(color: fill.opacity(0.28), radius: 4, x: 0, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .gesture(stepGesture)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint("Удерживай и веди вверх или вниз, чтобы поменять этаж")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: Text("Выбрать этаж"), onTap)
    }

    private var stepGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.24, maximumDistance: 16)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .onChanged { value in
                switch value {
                case .second(true, let drag):
                    if let drag {
                        handleDrag(drag)
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                if case .second(true, _) = value, !didStepDuringGesture {
                    onTap()
                }
                consumedDragSteps = 0
                didStepDuringGesture = false
            }
    }

    private func handleDrag(_ value: DragGesture.Value) {
        let rawSteps = Int((-value.translation.height / stepHeight).rounded(.towardZero))
        let delta = rawSteps - consumedDragSteps
        guard delta != 0 else { return }
        let direction: PersonalCartMarkerStepDirection = delta > 0 ? .up : .down
        for _ in 0..<abs(delta) {
            onStep(direction)
        }
        didStepDuringGesture = true
        consumedDragSteps = rawSteps
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
}

#Preview {
    PersonalCartMarkerStrip(
        markers: PersonalCartMarkers(
            aYellowFloor: 3,
            aGrayFloor: nil,
            bYellowFloor: 5,
            bGrayFloor: 2
        ),
        onTap: { _ in },
        onStep: { _, _ in }
    )
    .padding()
    .background(OceanKeyTheme.background)
}
