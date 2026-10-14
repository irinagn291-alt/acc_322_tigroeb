import Foundation

/// One friend on the phone. Phase on each fixture is folded, never a stored total.
struct Tipster: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var lines: [FixturePhase]
    var aimMarks: [AimMark]
    var sealMarks: [SealMark]
    var skewMarks: [SkewMark]
    var voidMarks: [VoidMark]
    var bullseyeMarks: [BullseyeMark]
    var nearMarks: [NearMark]
    var flats: [Flat]

    func line(for fixtureID: UUID) -> FixturePhase? {
        lines.first { $0.fixtureID == fixtureID }
    }

    mutating func updateLine(_ line: FixturePhase) {
        guard let index = lines.firstIndex(where: { $0.fixtureID == line.fixtureID }) else { return }
        lines[index] = line
    }
}

/// Open, Aimed, Sealed, Posted, or Void for one tipster on one fixture.
struct FixturePhase: Codable, Equatable, Sendable, Identifiable {
    var fixtureID: UUID
    var phase: BoardPhase
    var cell: Cell?

    var id: UUID { fixtureID }
}

enum BoardPhase: String, Codable, Equatable, Sendable {
    case open
    case aimed
    case sealed
    case posted
    case void
}
