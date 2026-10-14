import Foundation

/// Wrong winner on a posted fixture. Worth 0 points.
struct Flat: Codable, Equatable, Identifiable, Sendable {
    static let points = 0

    var id: UUID
    var tipsterID: UUID
    var fixtureID: UUID
    var cell: Cell
}
