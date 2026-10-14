import Foundation

/// One square on the 4×4 lattice. Home and away goals are each 0 through 3.
struct Cell: Codable, Equatable, Hashable, Sendable {
    var home: Int
    var away: Int

    var isOnLattice: Bool {
        (0...3).contains(home) && (0...3).contains(away)
    }

    /// Winner of this score. A tie is a draw.
    var winner: ScoreWinner {
        ScoreWinner.decide(home: home, away: away)
    }
}

/// Which side is ahead, or a draw when the goals match.
enum ScoreWinner: String, Codable, Equatable, Sendable {
    case home
    case away
    case draw

    static func decide(home: Int, away: Int) -> ScoreWinner {
        if home > away { return .home }
        if away > home { return .away }
        return .draw
    }
}
