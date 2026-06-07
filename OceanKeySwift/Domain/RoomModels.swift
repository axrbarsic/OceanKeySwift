import Foundation

enum RoomTask: String, CaseIterable, Identifiable {
    case stripped = "S"
    case linen = "L"
    case balcony = "B"

    var id: String { rawValue }
}

enum RoomStatus: String, CaseIterable {
    case pending
    case open
    case inProgress
    case ready
    case scheduled
}

struct RoomCell: Identifiable, Equatable {
    let id: String
    var status: RoomStatus
    var completedTasks: Set<RoomTask>
    var isVIP: Bool
    var scheduledTime: Date? = nil

    var isReady: Bool {
        completedTasks.count == RoomTask.allCases.count
    }
}

struct CartSection: Identifiable, Equatable {
    let id: Int
    var building: String
    var rooms: [RoomCell]
}

struct SummaryCounts: Equatable {
    var pending: Int
    var ready: Int
    var open: Int
}
