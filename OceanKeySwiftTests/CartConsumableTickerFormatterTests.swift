import Foundation
import Testing
@testable import OceanKeySwift

@Test
func cartConsumableTickerTextShowsActivePositiveItems() {
    let cart = testCart(consumables: [
        CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 4),
        CartConsumableItem(id: "sheet", title: "Простыни", quantity: 2)
    ])

    #expect(CartConsumableTickerFormatter.text(for: cart) == "Полотенца банные 4  •  Простыни 2")
}

@Test
func cartConsumableTickerTextIgnoresCompletedAndZeroQuantityItems() {
    let cart = testCart(consumables: [
        CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 4, completedAt: Date()),
        CartConsumableItem(id: "hand_towel", title: "Полотенца ручные", quantity: 0),
        CartConsumableItem(id: "sheet", title: "Простыни", quantity: 3)
    ])

    #expect(CartConsumableTickerFormatter.text(for: cart) == "Простыни 3")
}

@Test
func cartConsumableTickerTextIsNilWhenNothingIsNeeded() {
    let cart = testCart(consumables: [
        CartConsumableItem(id: "bath_towel", title: "Полотенца банные", quantity: 0),
        CartConsumableItem(id: "sheet", title: "Простыни", quantity: 1, completedAt: Date())
    ])

    #expect(CartConsumableTickerFormatter.text(for: cart) == nil)
}

private func testCart(consumables: [CartConsumableItem]) -> CartSection {
    CartSection(
        id: 7,
        building: "A3",
        rooms: [],
        note: nil,
        noteUpdatedAt: nil,
        mediaAttachments: nil,
        consumables: consumables
    )
}
