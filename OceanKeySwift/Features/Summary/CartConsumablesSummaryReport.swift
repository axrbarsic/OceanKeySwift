import Foundation

struct CartConsumableTotalNeed: Identifiable, Equatable {
    let itemID: CartConsumableItem.ID
    let title: String
    var quantity: Int

    var id: CartConsumableItem.ID { itemID }
}

struct CartConsumableCartNeed: Identifiable, Equatable {
    let cartID: CartSection.ID
    let itemID: CartConsumableItem.ID
    let title: String
    let quantity: Int

    var id: String { "\(cartID)-\(itemID)" }
}

struct CartConsumableCartSummary: Identifiable, Equatable {
    let id: CartSection.ID
    let building: String
    let needs: [CartConsumableCartNeed]
}

struct CartConsumablesSummaryReport: Equatable {
    let totals: [CartConsumableTotalNeed]
    let carts: [CartConsumableCartSummary]

    var isEmpty: Bool {
        totals.isEmpty && carts.isEmpty
    }
}

enum CartConsumablesSummaryBuilder {
    static func report(for carts: [CartSection]) -> CartConsumablesSummaryReport {
        var totalsByID: [CartConsumableItem.ID: CartConsumableTotalNeed] = [:]
        var totalOrder: [CartConsumableItem.ID] = []
        var cartSummaries: [CartConsumableCartSummary] = []

        for cart in carts {
            let needs = CartConsumableCatalog.merged(with: cart.consumables)
                .filter { $0.quantity > 0 && !$0.isCompleted }
                .map { item in
                    if totalsByID[item.id] == nil {
                        totalOrder.append(item.id)
                        totalsByID[item.id] = CartConsumableTotalNeed(
                            itemID: item.id,
                            title: item.title,
                            quantity: item.quantity
                        )
                    } else {
                        totalsByID[item.id]?.quantity += item.quantity
                    }

                    return CartConsumableCartNeed(
                        cartID: cart.id,
                        itemID: item.id,
                        title: item.title,
                        quantity: item.quantity
                    )
                }

            guard !needs.isEmpty else { continue }
            cartSummaries.append(
                CartConsumableCartSummary(
                    id: cart.id,
                    building: cart.building,
                    needs: needs
                )
            )
        }

        let totals = totalOrder.compactMap { totalsByID[$0] }
        return CartConsumablesSummaryReport(totals: totals, carts: cartSummaries)
    }
}
