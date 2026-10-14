import Foundation

/// Happy-path board for screenshots. Applied once, and only on the simulator.
enum DemoSeed {
    static let defaultsKey = "grc.demo.v1"

    static func chart(today: Int) -> BoardChart {
        let ada = UUID()
        let ben = UUID()
        let cora = UUID()
        let milltown = UUID()
        let loom = UUID()
        let wharf = UUID()
        let gatehouse = UUID()
        let future = DayKey.adding(days: 3, to: today)
        let past = DayKey.adding(days: -1, to: today)

        func line(_ fixture: UUID, _ phase: BoardPhase, _ cell: Cell?) -> FixturePhase {
            FixturePhase(fixtureID: fixture, phase: phase, cell: cell)
        }

        let adaMilltown = Cell(home: 2, away: 1)
        let wharfCell = Cell(home: 1, away: 0)
        let adaGate = Cell(home: 1, away: 1)
        let benGate = Cell(home: 0, away: 0)
        let coraGate = Cell(home: 2, away: 0)

        func tipster(
            id: UUID,
            name: String,
            lines: [FixturePhase],
            aims: [Cell],
            seals: [Cell],
            bullseye: Cell?,
            near: Cell?,
            flat: Cell?
        ) -> Tipster {
            Tipster(
                id: id,
                name: name,
                lines: lines,
                aimMarks: aims.map { AimMark(id: UUID(), tipsterID: id, fixtureID: milltown, cell: $0) }
                    + seals.map { AimMark(id: UUID(), tipsterID: id, fixtureID: wharf, cell: $0) }
                    + [bullseye, near, flat].compactMap { cell in
                        cell.map { AimMark(id: UUID(), tipsterID: id, fixtureID: gatehouse, cell: $0) }
                    },
                sealMarks: seals.map { SealMark(id: UUID(), tipsterID: id, fixtureID: wharf, cell: $0) }
                    + [bullseye, near, flat].compactMap { cell in
                        cell.map { SealMark(id: UUID(), tipsterID: id, fixtureID: gatehouse, cell: $0) }
                    },
                skewMarks: [],
                voidMarks: [],
                bullseyeMarks: bullseye.map {
                    [BullseyeMark(id: UUID(), tipsterID: id, fixtureID: gatehouse, cell: $0)]
                } ?? [],
                nearMarks: near.map {
                    [NearMark(id: UUID(), tipsterID: id, fixtureID: gatehouse, cell: $0)]
                } ?? [],
                flats: flat.map {
                    [Flat(id: UUID(), tipsterID: id, fixtureID: gatehouse, cell: $0)]
                } ?? []
            )
        }

        let adaTipster = tipster(
            id: ada,
            name: "Ada Quinn",
            lines: [
                line(milltown, .aimed, adaMilltown),
                line(loom, .open, nil),
                line(wharf, .sealed, wharfCell),
                line(gatehouse, .posted, adaGate)
            ],
            aims: [adaMilltown],
            seals: [wharfCell],
            bullseye: adaGate,
            near: nil,
            flat: nil
        )
        let benTipster = tipster(
            id: ben,
            name: "Ben Holt",
            lines: [
                line(milltown, .open, nil),
                line(loom, .open, nil),
                line(wharf, .sealed, wharfCell),
                line(gatehouse, .posted, benGate)
            ],
            aims: [],
            seals: [wharfCell],
            bullseye: nil,
            near: benGate,
            flat: nil
        )
        let coraTipster = tipster(
            id: cora,
            name: "Cora Voss",
            lines: [
                line(milltown, .open, nil),
                line(loom, .open, nil),
                line(wharf, .sealed, wharfCell),
                line(gatehouse, .posted, coraGate)
            ],
            aims: [],
            seals: [wharfCell],
            bullseye: nil,
            near: nil,
            flat: coraGate
        )

        return BoardChart(
            schemaVersion: BoardChart.currentSchema,
            tipsters: [adaTipster, benTipster, coraTipster],
            fixtures: [
                Fixture(id: milltown, homeSide: "Milltown", awaySide: "Harbor", kickoffDayKey: future, finalHome: nil, finalAway: nil),
                Fixture(id: loom, homeSide: "Loom End", awaySide: "Kiln Row", kickoffDayKey: future, finalHome: nil, finalAway: nil),
                Fixture(id: wharf, homeSide: "Wharf Lane", awaySide: "North Stair", kickoffDayKey: future, finalHome: nil, finalAway: nil),
                Fixture(id: gatehouse, homeSide: "Gatehouse", awaySide: "Low Market", kickoffDayKey: past, finalHome: 1, finalAway: 1)
            ],
            activeTipsterID: ada,
            activeFixtureID: milltown,
            onboardingComplete: true
        )
    }

    /// Writes the seed once. A device build never calls this.
    static func applyIfNeeded(to chart: inout BoardChart, defaults: UserDefaults, today: Int) -> Bool {
        #if targetEnvironment(simulator)
        if defaults.bool(forKey: defaultsKey) {
            return false
        }
        chart = Self.chart(today: today)
        defaults.set(true, forKey: defaultsKey)
        return true
        #else
        _ = chart
        _ = defaults
        _ = today
        return false
        #endif
    }
}
