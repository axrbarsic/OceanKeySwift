import Foundation

struct CartConsumableItem: Codable, Identifiable, Equatable, Sendable {
    let id: String
    var title: String
    var quantity: Int
    var updatedAt: Date?
    var completedAt: Date?
    var isHidden = false

    var isCompleted: Bool {
        completedAt != nil
    }
}

struct CartConsumableCatalogEntry: Codable, Identifiable, Equatable, Sendable {
    let id: String
    var title: String
    var isHidden: Bool = false
}

enum CartConsumableQuantity {
    static let maximum = 10

    static func clamped(_ quantity: Int) -> Int {
        min(max(0, quantity), maximum)
    }
}

enum CartConsumableCatalog {
    static let defaults: [CartConsumableItem] = [
        CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 0),
        CartConsumableItem(id: "hand_towel", title: "Полотенца ручные", quantity: 0),
        CartConsumableItem(id: "washcloth", title: "Салфетки", quantity: 0),
        CartConsumableItem(id: "bath_mat", title: "Коврики", quantity: 0),
        CartConsumableItem(id: "king_sheet", title: "King Sheets", quantity: 0),
        CartConsumableItem(id: "queen_sheet", title: "Queen Sheets", quantity: 0),
        CartConsumableItem(id: "sheet", title: "Простыни", quantity: 0),
        CartConsumableItem(id: "pillowcase", title: "Наволочки", quantity: 0),
        CartConsumableItem(id: "toilet_paper", title: "Туалетная бумага", quantity: 0),
        CartConsumableItem(id: "tissue", title: "Салфетки бумажные", quantity: 0)
    ]

    static let defaultIDs = Set(defaults.map(\.id))

    static var defaultEntries: [CartConsumableCatalogEntry] {
        defaults.map { item in
            CartConsumableCatalogEntry(
                id: item.id,
                title: item.title,
                isHidden: item.isHidden
            )
        }
    }

    static func merged(
        with storedItems: [CartConsumableItem]?,
        catalogEntries: [CartConsumableCatalogEntry]? = nil,
        includingHidden: Bool = false
    ) -> [CartConsumableItem] {
        let storedByID = Dictionary(uniqueKeysWithValues: (storedItems ?? []).map { ($0.id, $0) })
        let items: [CartConsumableItem]
        if let catalogEntries {
            let catalogIDs = Set(catalogEntries.map(\.id))
            let catalogItems = catalogEntries.map { entry in
                var item = storedByID[entry.id] ?? CartConsumableItem(
                    id: entry.id,
                    title: entry.title,
                    quantity: 0
                )
                item.title = entry.title
                item.isHidden = entry.isHidden
                return item
            }
            let legacyCustomItems = (storedItems ?? []).filter { item in
                !defaultIDs.contains(item.id) && !catalogIDs.contains(item.id)
            }
            items = catalogItems + legacyCustomItems
        } else {
            let customItems = (storedItems ?? []).filter { !defaultIDs.contains($0.id) }
            items = defaults.map { storedByID[$0.id] ?? $0 } + customItems
        }
        guard !includingHidden else { return items }
        return items.filter { !$0.isHidden }
    }

    static func normalizedEntries(_ entries: [CartConsumableCatalogEntry]) -> [CartConsumableCatalogEntry] {
        var entriesByID: [CartConsumableItem.ID: CartConsumableCatalogEntry] = [:]
        for entry in entries {
            entriesByID[entry.id] = entry
        }
        let defaultItems = defaultEntries.map { entriesByID[$0.id] ?? $0 }
        let customItems = entries.filter { !defaultIDs.contains($0.id) }
        return defaultItems + customItems
    }
}
