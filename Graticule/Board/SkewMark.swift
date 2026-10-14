import Foundation

/// A second aim without peel. The standing cell stays; this mark records the attempt.
struct SkewMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var tipsterID: UUID
    var fixtureID: UUID
    var attempted: Cell
}
