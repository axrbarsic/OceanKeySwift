import SwiftUI

struct CartConsumablesSection: View {
    let cartID: CartSection.ID
    @Bindable var workSession: WorkSessionStore
    @Bindable var appSettings: AppSettingsStore
    @Environment(\.interactionFeedback) private var feedback
    @State private var newConsumableTitle = ""

    private var items: [CartConsumableItem] {
        CartConsumableCatalog.merged(
            with: workSession.cart(id: cartID)?.consumables,
            catalogEntries: appSettings.cartConsumableCatalog
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            addConsumableRow

            ForEach(items) { item in
                CartConsumableRow(
                    item: item,
                    onRename: { title in
                        appSettings.renameCartConsumableCatalogItem(
                            itemID: item.id,
                            title: title
                        )
                    },
                    onDelete: {
                        appSettings.removeCartConsumableCatalogItem(itemID: item.id)
                        feedback.confirm()
                    },
                    onQuantityChange: { quantity in
                        workSession.updateCartConsumableQuantity(
                            itemID: item.id,
                            title: item.title,
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
        appSettings.addCartConsumableCatalogItem(title: newConsumableTitle)
        newConsumableTitle = ""
        feedback.confirm()
    }
}

private struct CartConsumableRow: View {
    let item: CartConsumableItem
    let onRename: (String) -> Void
    let onDelete: () -> Void
    let onQuantityChange: (Int) -> Void
    @State private var previewQuantity: Int?
    @State private var titleDraft: String
    @FocusState private var titleIsFocused: Bool

    init(
        item: CartConsumableItem,
        onRename: @escaping (String) -> Void,
        onDelete: @escaping () -> Void,
        onQuantityChange: @escaping (Int) -> Void
    ) {
        self.item = item
        self.onRename = onRename
        self.onDelete = onDelete
        self.onQuantityChange = onQuantityChange
        _titleDraft = State(initialValue: item.title)
    }

    private var visibleQuantity: Int {
        previewQuantity ?? item.quantity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    TextField("Название", text: $titleDraft)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                        .focused($titleIsFocused)
                        .onSubmit(commitTitle)

                    Text(statusText)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(statusColor.opacity(0.88))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .black))
                        .frame(width: 34, height: 34)
                        .foregroundStyle(OceanKeyTheme.open)
                        .background(.black.opacity(0.26))
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Удалить расходник")

                Text("\(visibleQuantity)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(statusColor)
                    .frame(minWidth: 42, alignment: .trailing)
            }

            CartConsumableQuantitySlider(
                quantity: item.quantity,
                onQuantityPreview: { previewQuantity = $0 },
                onQuantityChange: onQuantityChange
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(statusColor.opacity(visibleQuantity == 0 ? 0.16 : 0.38), lineWidth: 1)
        }
        .onChange(of: item.quantity) { _, _ in previewQuantity = nil }
        .onChange(of: item.title) { _, newValue in
            guard !titleIsFocused else { return }
            titleDraft = newValue
        }
        .onChange(of: titleIsFocused) { _, isFocused in
            if !isFocused {
                commitTitle()
            }
        }
    }

    private var rowBackground: Color {
        visibleQuantity == 0 ? .black.opacity(0.22) : OceanKeyTheme.accent.opacity(0.11)
    }

    private var statusColor: Color {
        visibleQuantity == 0 ? OceanKeyTheme.secondaryText : OceanKeyTheme.accent
    }

    private var statusText: String {
        visibleQuantity == 0 ? "Не нужно" : "Нужно \(visibleQuantity)"
    }

    private func commitTitle() {
        let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleDraft = item.title
            return
        }
        guard trimmed != item.title else { return }
        onRename(trimmed)
    }
}

#Preview {
    CartConsumablesSection(cartID: 7, workSession: .preview(), appSettings: AppSettingsStore())
        .padding()
        .background(OceanKeyTheme.background)
        .preferredColorScheme(.dark)
}
