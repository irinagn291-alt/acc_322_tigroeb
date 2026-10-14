import Foundation

/// Codable chart root. One record holds tipsters, fixtures, phases, cells, finals, and marks.
struct BoardChart: Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var tipsters: [Tipster]
    var fixtures: [Fixture]
    var activeTipsterID: UUID?
    var activeFixtureID: UUID?
    var onboardingComplete: Bool

    /// Empty fixture list is a blank board.
    var isBlank: Bool { fixtures.isEmpty }

    static func blank() -> BoardChart {
        BoardChart(
            schemaVersion: currentSchema,
            tipsters: [],
            fixtures: [],
            activeTipsterID: nil,
            activeFixtureID: nil,
            onboardingComplete: false
        )
    }

    func tipster(_ id: UUID) -> Tipster? {
        tipsters.first { $0.id == id }
    }

    func fixture(_ id: UUID) -> Fixture? {
        fixtures.first { $0.id == id }
    }

    mutating func replaceTipster(_ tipster: Tipster) {
        guard let index = tipsters.firstIndex(where: { $0.id == tipster.id }) else { return }
        tipsters[index] = tipster
    }

    mutating func replaceFixture(_ fixture: Fixture) {
        guard let index = fixtures.firstIndex(where: { $0.id == fixture.id }) else { return }
        fixtures[index] = fixture
    }
}

extension BoardChart: Codable {
    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case tipsters
        case fixtures
        case activeTipsterID
        case activeFixtureID
        case onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            tipsters = try container.decode([Tipster].self, forKey: .tipsters)
            fixtures = try container.decode([Fixture].self, forKey: .fixtures)
            activeTipsterID = try container.decodeIfPresent(UUID.self, forKey: .activeTipsterID)
            activeFixtureID = try container.decodeIfPresent(UUID.self, forKey: .activeFixtureID)
            onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported board schema \(version)."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(tipsters, forKey: .tipsters)
        try container.encode(fixtures, forKey: .fixtures)
        try container.encodeIfPresent(activeTipsterID, forKey: .activeTipsterID)
        try container.encodeIfPresent(activeFixtureID, forKey: .activeFixtureID)
        try container.encode(onboardingComplete, forKey: .onboardingComplete)
    }
}
