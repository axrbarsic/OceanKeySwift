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
            quickActionsRow
            addConsumableRow

            ForEach(items) { item in
                CartConsumableRow(
                    item: item,
                    onDecrement: {
                        workSession.updateCartConsumableQuantity(
                            itemID: item.id,
                            quantity: item.quantity - 1,
                            cartId: cartID
                        )
                    },
                    onIncrement: {
                        workSession.updateCartConsumableQuantity(
                            itemID: item.id,
                            quantity: item.quantity + 1,
                            cartId: cartID
                        )
                    },
                    onComplete: {
                        workSession.completeCartConsumable(
                            itemID: item.id,
                            cartId: cartID
                        )
                    },
                    onReopen: {
                        workSession.toggleCartConsumableCompletion(
                            itemID: item.id,
                            cartId: cartID
                        )
                    }
                )
            }
        }
    }

    private var quickActionsRow: some View {
        HStack(spacing: 10) {
            Label("Задания", systemImage: "shippingbox.fill")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer(minLength: 8)

            Button {
                workSession.clearCartConsumables(cartId: cartID)
                feedback.confirm()
            } label: {
                Label("Очистить всё", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .foregroundStyle(OceanKeyTheme.roomForeground)
                    .background(OceanKeyTheme.ready.opacity(canClear ? 1 : 0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canClear)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(OceanKeyTheme.ready.opacity(0.18), lineWidth: 1)
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

    private var canClear: Bool {
        items.contains { $0.quantity > 0 || $0.isCompleted }
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
    let onDecrement: () -> Void
    let onIncrement: () -> Void
    let onComplete: () -> Void
    let onReopen: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(subtitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(OceanKeyTheme.secondaryText.opacity(0.82))
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            completionButton

            HStack(spacing: 6) {
                quantityButton(systemName: "minus", action: onDecrement)

                Text("\(item.quantity)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .frame(width: 38)
                    .foregroundStyle(.white)

                quantityButton(systemName: "plus", action: onIncrement)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(item.isCompleted ? OceanKeyTheme.ready.opacity(0.42) : OceanKeyTheme.accent.opacity(0.14), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var completionButton: some View {
        if item.isCompleted {
            Button(action: onReopen) {
                Text("Вернуть")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(width: 62, height: 34)
                    .foregroundStyle(.white)
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)
        } else {
            Button(action: onComplete) {
                Text("Готово")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(width: 62, height: 34)
                    .foregroundStyle(OceanKeyTheme.roomForeground)
                    .background(OceanKeyTheme.ready.opacity(item.quantity > 0 ? 1 : 0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(item.quantity == 0)
        }
    }

    private var rowBackground: Color {
        item.isCompleted ? OceanKeyTheme.ready.opacity(0.12) : .black.opacity(0.24)
    }

    private var subtitle: String {
        if let completedAt = item.completedAt {
            return "Выполнено \(timeLabel(completedAt))"
        }
        if let updatedAt = item.updatedAt {
            return "Обновлено \(timeLabel(updatedAt))"
        }
        return "Не задано"
    }

    private func quantityButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .black))
                .frame(width: 36, height: 36)
                .foregroundStyle(OceanKeyTheme.roomForeground)
                .background(OceanKeyTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(systemName == "minus" && item.quantity == 0)
        .opacity(systemName == "minus" && item.quantity == 0 ? 0.35 : 1)
    }

    private func timeLabel(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
                .locale(Locale(identifier: "en_US_POSIX"))
        )
    }
}

#Preview {
    CartConsumablesSection(cartID: 7, workSession: .preview())
        .padding()
        .background(OceanKeyTheme.background)
        .preferredColorScheme(.dark)
}
