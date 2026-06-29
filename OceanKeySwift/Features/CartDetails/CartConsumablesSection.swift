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
                        appSettings.renameCartConsumableCatalogItem(itemID: item.id, title: title)
                    },
                    onDelete: {
                        appSettings.removeCartConsumableCatalogItem(itemID: item.id)
                        feedback.confirm()
                    },
                    onQuantityChange: { quantity in
                        setQuantity(item.id, item.title, quantity)
                    },
                    onToggleComplete: {
                        feedback.confirm()
                        workSession.toggleCartConsumableCompletion(itemID: item.id, cartId: cartID)
                    }
                )
            }
        }
        .padding(12)
        .background(MatrixConsumableStyle.panelFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(MatrixConsumableStyle.green.opacity(0.90), lineWidth: 1.2)
        }
    }

    private var addConsumableRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(MatrixConsumableStyle.green)

            TextField("Добавить расходник", text: $newConsumableTitle)
                .textInputAutocapitalization(.sentences)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(MatrixConsumableStyle.green)
                .submitLabel(.done)
                .onSubmit(addConsumable)

            Button(action: addConsumable) {
                Text("OK")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .frame(width: 48, height: 36)
                    .foregroundStyle(.black)
                    .background(
                        canAddConsumable ? MatrixConsumableStyle.green : .black.opacity(0.24),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canAddConsumable)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(MatrixConsumableStyle.rowFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(MatrixConsumableStyle.green.opacity(0.44), lineWidth: 1)
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

    private func setQuantity(
        _ itemID: CartConsumableItem.ID,
        _ title: String,
        _ quantity: Int
    ) {
        workSession.updateCartConsumableQuantity(
            itemID: itemID,
            title: title,
            quantity: CartConsumableQuantity.clamped(quantity),
            cartId: cartID
        )
        feedback.confirm()
    }
}

private struct CartConsumableRow: View {
    let item: CartConsumableItem
    let onRename: (String) -> Void
    let onDelete: () -> Void
    let onQuantityChange: (Int) -> Void
    let onToggleComplete: () -> Void

    @State private var previewQuantity: Int?
    @State private var pendingZeroCommit = false
    @State private var titleDraft: String
    @FocusState private var titleIsFocused: Bool

    init(
        item: CartConsumableItem,
        onRename: @escaping (String) -> Void,
        onDelete: @escaping () -> Void,
        onQuantityChange: @escaping (Int) -> Void,
        onToggleComplete: @escaping () -> Void
    ) {
        self.item = item
        self.onRename = onRename
        self.onDelete = onDelete
        self.onQuantityChange = onQuantityChange
        self.onToggleComplete = onToggleComplete
        _titleDraft = State(initialValue: item.title)
    }

    private var visibleQuantity: Int {
        previewQuantity ?? item.quantity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                HoldActionTarget(
                    enabled: visibleQuantity > 0,
                    useLongPress: true,
                    semanticLabel: "\(item.title) выполнено",
                    onActivate: onToggleComplete
                ) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28, weight: .black))
                        .frame(width: 42, height: 42)
                        .foregroundStyle(MatrixConsumableStyle.green)
                }

                VStack(alignment: .leading, spacing: 3) {
                    TextField("Название", text: $titleDraft)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(MatrixConsumableStyle.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                        .focused($titleIsFocused)
                        .onSubmit(commitTitle)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(MatrixConsumableStyle.green.opacity(0.68))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .black))
                        .frame(width: 34, height: 34)
                        .foregroundStyle(MatrixConsumableStyle.warningRed)
                        .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Удалить расходник")

                Text("\(visibleQuantity)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .frame(minWidth: 46, alignment: .trailing)
                    .foregroundStyle(MatrixConsumableStyle.green)
            }

            CartConsumableQuantitySlider(
                quantity: item.quantity,
                onQuantityPreview: { previewQuantity = $0 },
                onZeroCommitPendingChange: { pendingZeroCommit = $0 },
                onQuantityChange: onQuantityChange
            )

            if pendingZeroCommit {
                MatrixConsumableZeroWarning()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(strokeColor, lineWidth: 1)
        }
        .onChange(of: item.quantity) { _, _ in
            previewQuantity = nil
            pendingZeroCommit = false
        }
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
        item.isCompleted ? MatrixConsumableStyle.completedFill : MatrixConsumableStyle.rowFill
    }

    private var strokeColor: Color {
        MatrixConsumableStyle.green.opacity(item.isCompleted ? 0.98 : 0.82)
    }

    private var subtitle: String {
        if visibleQuantity == 0 {
            return "Не задано"
        }
        if let completedAt = item.completedAt {
            return "Выполнено \(timeLabel(completedAt))"
        }
        if let updatedAt = item.updatedAt {
            return "Обновлено \(timeLabel(updatedAt))"
        }
        return "Нужно \(visibleQuantity)"
    }

    private func timeLabel(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
                .locale(Locale(identifier: "en_US_POSIX"))
        )
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
