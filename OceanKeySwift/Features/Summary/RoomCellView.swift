import SwiftUI

struct RoomCellView: View {
    @Binding var room: RoomCell
    let onTaskToggle: (RoomTask) -> Void
    let onVIPToggle: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            Text(room.id)
                .font(.system(size: 46, weight: .black, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(RoomTask.allCases) { task in
                Button(action: { onTaskToggle(task) }) {
                    Text(task.rawValue)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(taskColor(task))
                        .frame(width: 48, height: 54)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 76)
        .foregroundStyle(.black)
        .background(cellBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(alignment: .topTrailing) {
            if room.isVIP {
                VIPPulseOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .onLongPressGesture(perform: onVIPToggle)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Room \(room.id)")
    }

    private var cellBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(OceanKeyTheme.fill(for: room.status))
            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 4)
    }

    private func taskColor(_ task: RoomTask) -> Color {
        room.completedTasks.contains(task) ? .black : .black.opacity(0.32)
    }
}

#Preview {
    @Previewable @State var room = WorkSessionStore.preview().carts[0].rooms[0]
    return RoomCellView(room: $room, onTaskToggle: { _ in }, onVIPToggle: {})
        .padding()
        .background(OceanKeyTheme.background)
}
