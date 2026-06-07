import Foundation
import Observation

@Observable
final class WorkSessionStore {
    var carts: [CartSection]

    init(carts: [CartSection]) {
        self.carts = carts
    }

    var counts: SummaryCounts {
        carts.flatMap(\.rooms).reduce(into: SummaryCounts(pending: 0, ready: 0, open: 0)) { counts, room in
            switch room.status {
            case .pending, .scheduled:
                counts.pending += 1
            case .open, .inProgress:
                counts.open += 1
            case .ready:
                counts.ready += 1
            }
        }
    }

    func toggleTask(_ task: RoomTask, roomId: RoomCell.ID) {
        mutateRoom(roomId) { room in
            if room.completedTasks.contains(task) {
                room.completedTasks.remove(task)
            } else {
                room.completedTasks.insert(task)
            }
            room.status = room.isReady ? .ready : room.completedTasks.isEmpty ? .open : .inProgress
        }
    }

    func toggleVIP(roomId: RoomCell.ID) {
        mutateRoom(roomId) { room in
            room.isVIP.toggle()
        }
    }

    private func mutateRoom(_ roomId: RoomCell.ID, update: (inout RoomCell) -> Void) {
        guard let cartIndex = carts.firstIndex(where: { cart in
            cart.rooms.contains(where: { $0.id == roomId })
        }) else { return }
        guard let roomIndex = carts[cartIndex].rooms.firstIndex(where: { $0.id == roomId }) else {
            return
        }
        update(&carts[cartIndex].rooms[roomIndex])
    }
}

extension WorkSessionStore {
    static func preview() -> WorkSessionStore {
        WorkSessionStore(carts: [
            CartSection(id: 7, building: "A3", rooms: [
                RoomCell(id: "303", status: .ready, completedTasks: Set(RoomTask.allCases), isVIP: true),
                RoomCell(id: "304", status: .ready, completedTasks: Set(RoomTask.allCases), isVIP: false),
                RoomCell(id: "305", status: .ready, completedTasks: Set(RoomTask.allCases), isVIP: false),
                RoomCell(id: "306", status: .scheduled, completedTasks: [], isVIP: false),
                RoomCell(id: "307", status: .open, completedTasks: [], isVIP: false),
                RoomCell(id: "308", status: .inProgress, completedTasks: [.stripped], isVIP: true)
            ]),
            CartSection(id: 8, building: "A4", rooms: [
                RoomCell(id: "401", status: .pending, completedTasks: [], isVIP: false),
                RoomCell(id: "402", status: .pending, completedTasks: [], isVIP: false)
            ])
        ])
    }
}
