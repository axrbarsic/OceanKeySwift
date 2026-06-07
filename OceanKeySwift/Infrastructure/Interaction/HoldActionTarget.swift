import SwiftUI

struct HoldActionTarget<Content: View>: View {
    let enabled: Bool
    let useLongPress: Bool
    let semanticLabel: String
    let onActivate: () -> Void
    @ViewBuilder let content: Content

    @Environment(\.interactionFeedback) private var feedback
    @State private var warningTask: Task<Void, Never>?

    var body: some View {
        content
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(semanticLabel)
            .gesture(tapGesture)
            .onLongPressGesture(
                minimumDuration: useLongPress ? 0.46 : 999,
                maximumDistance: 18,
                pressing: handlePressing,
                perform: activateLongPress
            )
    }

    private var tapGesture: some Gesture {
        TapGesture().onEnded {
            guard enabled, !useLongPress else {
                if !enabled {
                    feedback.invalid()
                }
                return
            }
            feedback.tap()
            onActivate()
        }
    }

    private func handlePressing(_ pressing: Bool) {
        guard enabled, useLongPress else { return }
        if pressing {
            feedback.holdStart()
            warningTask?.cancel()
            warningTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(330))
                if !Task.isCancelled {
                    feedback.holdWarning()
                }
            }
        } else {
            warningTask?.cancel()
            warningTask = nil
        }
    }

    private func activateLongPress() {
        guard enabled, useLongPress else { return }
        warningTask?.cancel()
        warningTask = nil
        feedback.holdCommit()
        onActivate()
    }
}
