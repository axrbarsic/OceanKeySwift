import SwiftUI

enum OceanKeyTheme {
    static let background = Color(red: 0.016, green: 0.031, blue: 0.020)
    static let surface = Color(red: 0.008, green: 0.016, blue: 0.008)
    static let accent = Color(red: 0.118, green: 1.000, blue: 0.353)
    static let mutedText = Color(red: 0.294, green: 0.702, blue: 0.396)
    static let secondaryText = Color(red: 0.608, green: 1.000, blue: 0.722)
    static let ready = Color(red: 0.035, green: 0.940, blue: 0.020)
    static let pending = Color(red: 1.000, green: 0.820, blue: 0.145)
    static let open = Color(red: 1.000, green: 0.180, blue: 0.180)
    static let inProgress = Color(red: 0.110, green: 0.420, blue: 1.000)
    static let scheduled = Color(red: 1.000, green: 0.230, blue: 0.700)

    static func fill(for status: RoomStatus) -> Color {
        switch status {
        case .pending: pending
        case .open: open
        case .inProgress: inProgress
        case .ready: ready
        case .scheduled: scheduled
        }
    }
}
