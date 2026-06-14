import SwiftUI

struct CartConsumablesSummaryTable: View {
    let report: CartConsumablesSummaryReport
    let onComplete: (CartSection.ID, CartConsumableItem.ID) -> Void

    @Environment(\.interactionFeedback) private var feedback

    var body: some View {
        if !report.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label("Расходники на склад", systemImage: "shippingbox.and.arrow.backward.fill")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                totalsPanel
                cartsPanel
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(.black.opacity(0.22))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(OceanKeyTheme.pending.opacity(0.26), lineWidth: 1)
            }
            .accessibilityElement(children: .contain)
        }
    }

    private var totalsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            panelHeader("Всего взять", systemImage: "sum")

            ForEach(report.totals) { total in
                HStack(spacing: 10) {
                    Text(total.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 8)

                    quantityBadge(total.quantity, color: OceanKeyTheme.pending)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(12)
        .background(.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var cartsPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            panelHeader("По тележкам", systemImage: "list.bullet.rectangle.fill")

            ForEach(report.carts) { cart in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Тележка \(cart.id)")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(cart.building)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(OceanKeyTheme.secondaryText)
                            .lineLimit(1)

                        Spacer(minLength: 8)
                    }

                    ForEach(cart.needs) { need in
                        CartConsumablesSummaryNeedRow(
                            need: need,
                            onComplete: {
                                feedback.confirm()
                                onComplete(need.cartID, need.itemID)
                            }
                        )
                    }
                }
                .padding(10)
                .background(.white.opacity(0.055))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(12)
        .background(.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func panelHeader(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(OceanKeyTheme.secondaryText)
            .textCase(.uppercase)
            .lineLimit(1)
    }

    private func quantityBadge(_ quantity: Int, color: Color) -> some View {
        Text("\(quantity)")
            .font(.system(size: 17, weight: .black, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(OceanKeyTheme.roomForeground)
            .frame(minWidth: 38, minHeight: 30)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

private struct CartConsumablesSummaryNeedRow: View {
    let need: CartConsumableCartNeed
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(need.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Text("\(need.quantity)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(OceanKeyTheme.pending)
                .frame(width: 28)

            Button(action: onComplete) {
                Label("Готово", systemImage: "checkmark")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .labelStyle(.titleAndIcon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(width: 82, height: 34)
                    .foregroundStyle(OceanKeyTheme.roomForeground)
                    .background(OceanKeyTheme.ready)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 8)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .background(.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contentShape(Rectangle())
        .onLongPressGesture {
            onComplete()
        }
        .accessibilityHint("Долгое нажатие или кнопка Готово закрывает эту позицию")
    }
}
