import Foundation

/// A match on the week board. Kickoff is a YYYYMMDD daykey, not a timestamp.
struct Fixture: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var homeSide: String
    var awaySide: String
    var kickoffDayKey: Int
    /// Typed final score. Totals may sit above the lattice.
    var finalHome: Int?
    var finalAway: Int?

    var title: String { "\(homeSide) versus \(awaySide)" }

    var hasFinalScore: Bool {
        finalHome != nil && finalAway != nil
    }
}
