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
func readyCountTracksCompletedRooms() {
    let store = WorkSessionStore.preview()

    #expect(store.counts.ready == 3)
}
