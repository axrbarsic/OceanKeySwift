import SwiftUI

struct VoiceTranscriptionPanel: View {
    @Environment(\.interactionFeedback) private var feedback

    let title: String
    @Binding var transcript: String
    @State private var controller = VoiceTranscriptionController()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: toggleRecording) {
                HStack(spacing: 12) {
                    Image(systemName: controller.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(controller.isRecording ? OceanKeyTheme.open : OceanKeyTheme.accent)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(controller.isRecording ? "Остановить" : title)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text(controller.statusText)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(OceanKeyTheme.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding(14)
                .background(.black.opacity(controller.isRecording ? 0.34 : 0.20))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            (controller.isRecording ? OceanKeyTheme.open : OceanKeyTheme.accent).opacity(0.28),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)

            if controller.isRecording {
                Text("Говори по-русски. Текст ниже обновляется на лету.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(OceanKeyTheme.secondaryText.opacity(0.74))
            }
        }
        .onDisappear {
            controller.stop()
        }
    }

    private func toggleRecording() {
        if controller.isRecording {
            feedback.confirm()
        } else {
            feedback.longPress()
        }
        controller.toggle(transcript: transcript) { newTranscript in
            transcript = newTranscript
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    return VoiceTranscriptionPanel(title: "Голосовая заметка", transcript: $text)
        .padding()
        .background(OceanKeyTheme.background)
}
