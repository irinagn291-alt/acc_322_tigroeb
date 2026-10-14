import Foundation

/// Append-only record that a tipster aimed a cell on a fixture.
struct AimMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var tipsterID: UUID
    var fixtureID: UUID
    var cell: Cell
}
