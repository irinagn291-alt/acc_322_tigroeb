import Foundation

/// Kickoff arrived while this tipster was still Open or Aimed.
struct VoidMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var tipsterID: UUID
    var fixtureID: UUID
}
