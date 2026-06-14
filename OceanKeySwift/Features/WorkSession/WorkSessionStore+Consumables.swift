import Foundation

extension WorkSessionStore {
    func addCartConsumable(
        title: String,
        quantity: Int = 0,
        cartId: CartSection.ID
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let safeQuantity = CartConsumableQuantity.clamped(quantity)

        mutateCart(cartId, history: { _, after, _ in
            (.cartConsumablesChanged, "Тележка \(after.id): добавлен расходник \(trimmed)")
        }) { cart in
            var items = CartConsumableCatalog.merged(with: cart.consumables)
            items.append(
                CartConsumableItem(
                    id: "custom_\(UUID().uuidString)",
                    title: trimmed,
                    quantity: safeQuantity,
                    updatedAt: Date(),
                    completedAt: nil
                )
            )
            cart.consumables = items
        }
    }

    func updateCartConsumableQuantity(
        itemID: CartConsumableItem.ID,
        quantity: Int,
        cartId: CartSection.ID
    ) {
        let safeQuantity = CartConsumableQuantity.clamped(quantity)
        mutateCart(cartId, history: { _, after, _ in
            let item = CartConsumableCatalog.merged(with: after.consumables).first { $0.id == itemID }
            let title = item?.title ?? "Расходник"
            return (.cartConsumablesChanged, "Тележка \(after.id): \(title) \(safeQuantity)")
        }) { cart in
            let changedAt = Date()
            var items = CartConsumableCatalog.merged(with: cart.consumables)
            guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
            items[index].quantity = safeQuantity
            items[index].updatedAt = changedAt
            items[index].completedAt = nil
            cart.consumables = items
        }
    }

    func completeCartConsumable(
        itemID: CartConsumableItem.ID,
        cartId: CartSection.ID
    ) {
        mutateCart(cartId, history: { _, after, _ in
            let item = CartConsumableCatalog.merged(with: after.consumables).first { $0.id == itemID }
            let title = item?.title ?? "Расходник"
            return (.cartConsumablesChanged, "Тележка \(after.id): \(title) выполнено")
        }) { cart in
            let changedAt = Date()
            var items = CartConsumableCatalog.merged(with: cart.consumables)
            guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
            guard items[index].quantity > 0, items[index].completedAt == nil else { return }
            items[index].completedAt = changedAt
            items[index].updatedAt = changedAt
            cart.consumables = items
        }
    }

    func clearCartConsumables(cartId: CartSection.ID) {
        mutateCart(cartId, history: { _, after, _ in
            (.cartConsumablesChanged, "Тележка \(after.id): расходники очищены")
        }) { cart in
            let changedAt = Date()
            var items = CartConsumableCatalog.merged(with: cart.consumables)
            var didReset = false
            for index in items.indices where items[index].quantity > 0 || items[index].completedAt != nil {
                items[index].quantity = 0
                items[index].completedAt = nil
                items[index].updatedAt = changedAt
                didReset = true
            }
            guard didReset else { return }
            cart.consumables = items
        }
    }

    func toggleCartConsumableCompletion(
        itemID: CartConsumableItem.ID,
        cartId: CartSection.ID
    ) {
        mutateCart(cartId, history: { _, after, _ in
            let item = CartConsumableCatalog.merged(with: after.consumables).first { $0.id == itemID }
            let title = item?.title ?? "Расходник"
            let suffix = item?.isCompleted == true ? "выполнено" : "снова в работе"
            return (.cartConsumablesChanged, "Тележка \(after.id): \(title) \(suffix)")
        }) { cart in
            let changedAt = Date()
            var items = CartConsumableCatalog.merged(with: cart.consumables)
            guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
            items[index].completedAt = items[index].completedAt == nil ? changedAt : nil
            items[index].updatedAt = changedAt
            cart.consumables = items
        }
    }
}
