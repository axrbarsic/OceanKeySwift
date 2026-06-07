import Foundation

struct BuildChangelogEntry: Identifiable, Equatable {
    let id = UUID()
    let version: String
    let date: String
    let changes: [String]
}

enum BuildChangelog {
    static let entries = [
        BuildChangelogEntry(
            version: "0.2.0 (13)",
            date: "2026-06-06",
            changes: [
                "Added a settings switch between taller first-test cells and compact Flutter-parity cells.",
                "Restored the taller first-test room-cell geometry as a deliberate Swift-only visual exception.",
                "Native Swift rewrite runs on physical iPhone with SpriteKit Matrix background.",
                "Main screen has cart sections, room cells, S/L/B actions, VIP, schedule, and one-open swipe menu.",
                "Room and cart state now persists locally through Application Support JSON storage.",
                "Room text notes, voice transcript drafts, cart notes, and local photo/video attachments are domain data.",
                "Room and cart media use native camera capture and local thumbnail previews.",
                "Settings screen shows build, diagnostics basics, and this changelog."
            ]
        )
    ]
}
