import Testing
@testable import OceanKeySwift

@Test
func taskToggleUpdatesRoomStatus() {
    let store = WorkSessionStore.preview()

    store.toggleTask(.stripped, roomId: "307")

    let room = store.carts.flatMap(\.rooms).first { $0.id == "307" }
    #expect(room?.status == .inProgress)
    #expect(room?.completedTasks == [.stripped])
}

@Test
func taskToggleRequiresOpenRoom() {
    let store = WorkSessionStore.preview()

    store.toggleTask(.stripped, roomId: "401")

    let room = store.room(id: "401")
    #expect(room?.opened == false)
    #expect(room?.completedTasks.isEmpty == true)
    #expect(room?.status == .pending)
}

@Test
func readyStatusRequiresOpenRoom() {
    let room = RoomCell(
        id: "999",
        opened: false,
        completedTasks: Set(RoomTask.allCases),
        isVIP: false
    )

    #expect(room.isReady == false)
    #expect(room.status == .inProgress)
}

@Test
func readyCountTracksCompletedRooms() {
    let store = WorkSessionStore.preview()

    #expect(store.counts.completed == 3)
}

@Test
func catalogMatchesKnownTerritories() {
    let a2 = RoomCatalog.territory(id: "A2")
    let b5 = RoomCatalog.territory(id: "B5")

    #expect(a2?.rooms.contains("210A") == true)
    #expect(a2?.rooms.contains("210B") == true)
    #expect(b5?.rooms.first == "511")
    #expect(b5?.rooms.last == "529")
}

@Test
func roomSelectionPreventsCrossCartDuplicates() {
    var selection = WorkSessionSelectionState()
    selection.toggleCart(1)
    selection.toggleCart(2)

    #expect(selection.toggleRoom(cartNumber: 1, room: "518") == .changed)
    #expect(selection.toggleRoom(cartNumber: 2, room: "518") == .blocked)
    #expect(selection.rooms(forCart: 1).contains("518"))
    #expect(!selection.rooms(forCart: 2).contains("518"))
}

@Test
func storeSelectionRebuildsCartsWhilePreservingRoomState() {
    let store = WorkSessionStore(carts: [])
    store.toggleCartSelection(7)
    store.toggleRoomSelection(cartNumber: 7, room: "303")
    store.toggleOpen(roomId: "303")
    store.toggleTask(.stripped, roomId: "303")

    store.toggleRoomSelection(cartNumber: 7, room: "304")

    let room303 = store.room(id: "303")
    #expect(room303?.opened == true)
    #expect(room303?.completedTasks == [.stripped])
    #expect(store.room(id: "304")?.status == .pending)
}

@Test
func lockedWorkdayIgnoresSelectionEdits() {
    var selection = WorkSessionSelectionState()
    selection.toggleCart(7)
    selection.toggleRoom(cartNumber: 7, room: "303")

    #expect(selection.lockWorkday() == .changed)
    #expect(selection.toggleRoom(cartNumber: 7, room: "304") == .ignored)
    #expect(!selection.rooms(forCart: 7).contains("304"))
}
