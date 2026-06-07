import CoreGraphics
import Foundation
import Observation

enum RoomCellGeometry: String, CaseIterable, Codable, Identifiable {
    case roomy
    case compact

    var id: String { rawValue }

    var title: String {
        switch self {
        case .roomy:
            "Крупные"
        case .compact:
            "Компактные"
        }
    }

    var description: String {
        switch self {
        case .roomy:
            "Первый Swift-тест"
        case .compact:
            "Плотный Flutter-parity"
        }
    }

    var sectionSpacing: CGFloat {
        switch self {
        case .roomy: 10
        case .compact: 7
        }
    }

    var sectionHorizontalPadding: CGFloat {
        switch self {
        case .roomy: 6
        case .compact: 5
        }
    }

    var taskSpacing: CGFloat {
        switch self {
        case .roomy: 18
        case .compact: 6
        }
    }

    var tileLeadingPadding: CGFloat {
        switch self {
        case .roomy: 20
        case .compact: 14
        }
    }

    var tileTrailingPadding: CGFloat {
        switch self {
        case .roomy: 20
        case .compact: 8
        }
    }

    var tileHeight: CGFloat {
        switch self {
        case .roomy: 76
        case .compact: 66
        }
    }

    var tileCornerRadius: CGFloat {
        switch self {
        case .roomy: 14
        case .compact: 13
        }
    }

    var tileShadowOpacity: Double {
        switch self {
        case .roomy: 0.25
        case .compact: 0.23
        }
    }
}

@Observable
final class AppSettingsStore {
    private enum Keys {
        static let roomCellGeometry = "roomCellGeometry"
        static let roomTaskLongPress = "roomTaskLongPress"
    }

    @ObservationIgnored private let userDefaults: UserDefaults

    var roomCellGeometry: RoomCellGeometry {
        didSet {
            userDefaults.set(roomCellGeometry.rawValue, forKey: Keys.roomCellGeometry)
        }
    }

    var roomTaskLongPress: Bool {
        didSet {
            userDefaults.set(roomTaskLongPress, forKey: Keys.roomTaskLongPress)
        }
    }

    init(
        roomCellGeometry: RoomCellGeometry = .roomy,
        roomTaskLongPress: Bool = true,
        userDefaults: UserDefaults = .standard
    ) {
        self.roomCellGeometry = roomCellGeometry
        self.roomTaskLongPress = roomTaskLongPress
        self.userDefaults = userDefaults
    }

    static func load(userDefaults: UserDefaults = .standard) -> AppSettingsStore {
        let rawValue = userDefaults.string(forKey: Keys.roomCellGeometry)
        let geometry = rawValue.flatMap(RoomCellGeometry.init(rawValue:)) ?? .roomy
        let roomTaskLongPress = userDefaults.object(forKey: Keys.roomTaskLongPress) as? Bool ?? true
        return AppSettingsStore(
            roomCellGeometry: geometry,
            roomTaskLongPress: roomTaskLongPress,
            userDefaults: userDefaults
        )
    }
}
