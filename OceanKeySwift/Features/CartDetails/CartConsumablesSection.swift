import SwiftUI

struct CartConsumablesSection: View {
    let cartID: CartSection.ID
    @Bindable var workSession: WorkSessionStore
    @Environment(\.interactionFeedback) private var feedback
    @State private var newConsumableTitle = ""

    private var items: [CartConsumableItem] {
        CartConsumableCatalog.merged(with: workSession.cart(id: cartID)?.consumables)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            addConsumableRow

            ForEach(items) { item in
                CartConsumableRow(
                    item: item,
                    onQuantityChange: { quantity in
                        workSession.updateCartConsumableQuantity(
                            itemID: item.id,
                            quantity: quantity,
                            cartId: cartID
                        )
                        feedback.confirm()
                    }
                )
            }
        }
    }

    private var addConsumableRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(OceanKeyTheme.accent)

            TextField("Добавить расходник", text: $newConsumableTitle)
                .textInputAutocapitalization(.sentences)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .submitLabel(.done)
                .onSubmit(addConsumable)

            Button(action: addConsumable) {
                Text("OK")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .frame(width: 48, height: 36)
                    .foregroundStyle(OceanKeyTheme.roomForeground)
                    .background(OceanKeyTheme.accent.opacity(canAddConsumable ? 1 : 0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canAddConsumable)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(OceanKeyTheme.accent.opacity(0.14), lineWidth: 1)
        }
    }

    private var canAddConsumable: Bool {
        !newConsumableTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addConsumable() {
        guard canAddConsumable else { return }
        workSession.addCartConsumable(title: newConsumableTitle, cartId: cartID)
        newConsumableTitle = ""
        feedback.confirm()
    }
}

private struct CartConsumableRow: View {
    let item: CartConsumableItem
    let onQuantityChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(statusText)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(statusColor.opacity(0.88))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text("\(item.quantity)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(statusColor)
                    .frame(minWidth: 42, alignment: .trailing)
            }

            CartConsumableQuantitySlider(
                quantity: item.quantity,
                onQuantityChange: onQuantityChange
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(statusColor.opacity(item.quantity == 0 ? 0.16 : 0.38), lineWidth: 1)
        }
    }

    private var rowBackground: Color {
        item.quantity == 0 ? .black.opacity(0.22) : OceanKeyTheme.accent.opacity(0.11)
    }

    private var statusColor: Color {
        item.quantity == 0 ? OceanKeyTheme.secondaryText : OceanKeyTheme.accent
    }

    private var statusText: String {
        item.quantity == 0 ? "Не нужно" : "Нужно \(item.quantity)"
    }
}

#Preview {
    CartConsumablesSection(cartID: 7, workSession: .preview())
        .padding()
        .background(OceanKeyTheme.background)
        .preferredColorScheme(.dark)
}
