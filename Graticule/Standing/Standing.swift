import Foundation

/// Sum of posted points for one tipster. Derived. Never written to the chart.
struct Standing: Equatable, Sendable, Identifiable {
    var tipsterID: UUID
    var name: String
    var points: Int

    var id: UUID { tipsterID }
}
