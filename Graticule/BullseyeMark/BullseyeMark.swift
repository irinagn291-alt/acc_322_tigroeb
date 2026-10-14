import Foundation

/// Exact cell on a posted fixture. Worth 9 points. The points are not stored.
struct BullseyeMark: Codable, Equatable, Identifiable, Sendable {
    static let points = 9

    var id: UUID
    var tipsterID: UUID
    var fixtureID: UUID
    var cell: Cell
}
