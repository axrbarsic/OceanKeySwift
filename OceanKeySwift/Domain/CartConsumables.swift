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

    static func merged(
        with storedItems: [CartConsumableItem]?,
        includingHidden: Bool = false
    ) -> [CartConsumableItem] {
        let storedByID = Dictionary(uniqueKeysWithValues: (storedItems ?? []).map { ($0.id, $0) })
        let customItems = (storedItems ?? []).filter { !defaultIDs.contains($0.id) }
        let items = defaults.map { storedByID[$0.id] ?? $0 } + customItems
        guard !includingHidden else { return items }
        return items.filter { !$0.isHidden }
    }
}
