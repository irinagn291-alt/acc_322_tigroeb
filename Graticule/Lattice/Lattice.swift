import Foundation

/// The 4×4 score lattice fused on an open fixture. Empty cells stay honest squares.
enum Lattice {
    static let span = 4

    static var cells: [Cell] {
        (0..<span).flatMap { home in
            (0..<span).map { away in
                Cell(home: home, away: away)
            }
        }
    }
}
