import Foundation

protocol WorkSessionRepository {
    func loadSnapshot() throws -> WorkSessionSnapshot?
    func save(snapshot: WorkSessionSnapshot) throws
}
