import SwiftUI

struct CartConsumablesSummaryTable: View {
    let report: CartConsumablesSummaryReport
    let onQuantityChange: (CartSection.ID, CartConsumableItem.ID, String, Int) -> Void

    var body: some View {
        if !report.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                SummaryConsumablesPanel {
                    ForEach(report.totals) { item in
                        SummaryConsumableTotalRow(item: item)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .accessibilityElement(children: .contain)
        }
    }
}

private struct SummaryConsumablesPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(MatrixConsumableStyle.panelFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(MatrixConsumableStyle.green.opacity(0.95), lineWidth: 1.4)
        }
        .shadow(color: MatrixConsumableStyle.green.opacity(0.10), radius: 10)
    }
}

private struct SummaryConsumableTotalRow: View {
    let item: CartConsumableTotalNeed

    var body: some View {
        HStack(spacing: 10) {
            Text(item.title)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(MatrixConsumableStyle.green)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Spacer(minLength: 8)

            Text("\(item.quantity)")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(MatrixConsumableStyle.green)
                .frame(minWidth: 68, minHeight: 60)
                .background(.black.opacity(0.20), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(MatrixConsumableStyle.green.opacity(0.95), lineWidth: 1.2)
                }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
    }
}
