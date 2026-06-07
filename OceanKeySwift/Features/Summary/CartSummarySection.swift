import SwiftUI

struct CartSummarySection: View {
    @Binding var cart: CartSection
    let onTaskToggle: (RoomTask, RoomCell.ID) -> Void
    let onVIPToggle: (RoomCell.ID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Label("Тележка \(cart.id)", systemImage: "circle.fill")
                    .labelStyle(.titleAndIcon)
                Spacer()
                Text(cart.building)
            }
            .font(.system(size: 30, weight: .black, design: .rounded))
            .foregroundStyle(.white)

            ForEach($cart.rooms) { $room in
                RoomCellView(
                    room: $room,
                    onTaskToggle: { task in onTaskToggle(task, room.id) },
                    onVIPToggle: { onVIPToggle(room.id) }
                )
            }
        }
        .padding(.horizontal, 6)
    }
}

#Preview {
    @Previewable @State var cart = WorkSessionStore.preview().carts[0]
    return CartSummarySection(cart: $cart, onTaskToggle: { _, _ in }, onVIPToggle: { _ in })
        .background(OceanKeyTheme.background)
}
