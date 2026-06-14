import Testing
import Foundation
@testable import OceanKeySwift

@Test
func consumablesSummaryAggregatesActiveNeedsAcrossCarts() {
    let carts = [
        CartSection(
            id: 3,
            building: "A3",
            rooms: [],
            consumables: [
                CartConsumableItem(id: "toilet_paper", title: "Туалетная бумага", quantity: 2),
                CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 4)
            ]
        ),
        CartSection(
            id: 5,
            building: "B5",
            rooms: [],
            consumables: [
                CartConsumableItem(id: "toilet_paper", title: "Туалетная бумага", quantity: 5),
                CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 3, completedAt: Date()),
                CartConsumableItem(id: "queen_sheet", title: "Queen Sheets", quantity: 0)
            ]
        )
    ]

    let report = CartConsumablesSummaryBuilder.report(for: carts)

    #expect(report.totals.first { $0.itemID == "toilet_paper" }?.quantity == 7)
    #expect(report.totals.first { $0.itemID == "bath_towel" }?.quantity == 4)
    #expect(report.totals.count == 2)
    #expect(report.carts.map(\.id) == [3, 5])
    #expect(report.carts.first { $0.id == 5 }?.needs.map(\.itemID) == ["toilet_paper"])
}

@Test
func consumablesSummaryIsEmptyWhenNeedsAreZeroOrCompleted() {
    let carts = [
        CartSection(
            id: 3,
            building: "A3",
            rooms: [],
            consumables: [
                CartConsumableItem(id: "toilet_paper", title: "Туалетная бумага", quantity: 0),
                CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 4, completedAt: Date())
            ]
        )
    ]

    let report = CartConsumablesSummaryBuilder.report(for: carts)

    #expect(report.isEmpty)
}

@Test
func consumableCatalogEditsApplyToAllCarts() {
    let catalog = CartConsumableCatalog.normalizedEntries([
        CartConsumableCatalogEntry(id: "bath_towel", title: "Pool towels"),
        CartConsumableCatalogEntry(id: "hand_towel", title: "Полотенца ручные", isHidden: true),
        CartConsumableCatalogEntry(id: "custom_coffee", title: "Coffee pods")
    ])
    let carts = [
        CartSection(
            id: 3,
            building: "A3",
            rooms: [],
            consumables: [
                CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 2),
                CartConsumableItem(id: "hand_towel", title: "Полотенца ручные", quantity: 5),
                CartConsumableItem(id: "custom_coffee", title: "Coffee pods", quantity: 1)
            ]
        ),
        CartSection(
            id: 5,
            building: "B5",
            rooms: [],
            consumables: [
                CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 3),
                CartConsumableItem(id: "hand_towel", title: "Полотенца ручные", quantity: 4)
            ]
        )
    ]

    let report = CartConsumablesSummaryBuilder.report(for: carts, catalogEntries: catalog)

    #expect(report.totals.first { $0.itemID == "bath_towel" }?.title == "Pool towels")
    #expect(report.totals.first { $0.itemID == "bath_towel" }?.quantity == 5)
    #expect(report.totals.first { $0.itemID == "custom_coffee" }?.quantity == 1)
    #expect(!report.totals.contains { $0.itemID == "hand_towel" })
}
