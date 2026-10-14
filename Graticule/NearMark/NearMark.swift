import Foundation

/// Correct winner, different score, on a posted fixture. Worth 3 points.
struct NearMark: Codable, Equatable, Identifiable, Sendable {
    static let points = 3

    var id: UUID
    var tipsterID: UUID
    var fixtureID: UUID
    var cell: Cell
}
