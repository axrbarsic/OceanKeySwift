import SwiftUI

struct RoomMediaIndicator: View {
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

// Кэш формата: body VIP-ячейки пересчитывается каждый кадр (TimelineView),
// создавать DateFormatter на каждый проход — лишние аллокации.
private let roomScheduleLabelFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "h:mm a"
    return formatter
}()

extension RoomCell {
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
