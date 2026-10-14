import Foundation

/// Freezes the aimed cell before the kickoff daykey.
struct SealMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var tipsterID: UUID
    var fixtureID: UUID
    var cell: Cell
}
