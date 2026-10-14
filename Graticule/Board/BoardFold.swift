import Foundation

/// Grid fold. Aim, Seal, Post, and Peel are the only writers of phase.
enum BoardFold {
    enum Refusal: Equatable, Sendable {
        case unknownFixture
        case unknownTipster
        case invalidCell
        case aimRefused
        case notAimed
        case sealAfterKickoff
        case peelRefused
        case postBeforeKickoff
        case negativeScore
        case emptyName
        case invalidDayKey
    }

    struct Outcome: Equatable, Sendable {
        var chart: BoardChart
        var refusal: Refusal?
        var bullseyeLanded: Bool
    }

    /// Score = 100 × (1 + confidence/100) if correct, else 0. One pick, locked before the result.
    static func score(correct: Bool, confidence: Int) -> Int {
        guard correct else { return 0 }
        return 100 * (1 + confidence / 100)
    }

    /// Lattice weights stay 9, 3, and 0. A miss scores 0, so those weights apply only when the pick is correct.
    static func postedPoints(for tipster: Tipster) -> Int {
        func weight(correct: Bool, points: Int, count: Int) -> Int {
            guard count > 0 else { return 0 }
            guard score(correct: correct, confidence: 0) > 0 else { return 0 }
            return count * points
        }
        return weight(correct: true, points: BullseyeMark.points, count: tipster.bullseyeMarks.count)
            + weight(correct: true, points: NearMark.points, count: tipster.nearMarks.count)
            + weight(correct: false, points: Flat.points, count: tipster.flats.count)
    }

    static func standings(in chart: BoardChart) -> [Standing] {
        chart.tipsters.map { tipster in
            Standing(tipsterID: tipster.id, name: tipster.name, points: postedPoints(for: tipster))
        }
    }

    static func addTipster(name: String, to chart: BoardChart) -> Outcome {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return Outcome(chart: chart, refusal: .emptyName, bullseyeLanded: false)
        }
        var next = chart
        let tipster = Tipster(
            id: UUID(),
            name: trimmed,
            lines: next.fixtures.map { FixturePhase(fixtureID: $0.id, phase: .open, cell: nil) },
            aimMarks: [],
            sealMarks: [],
            skewMarks: [],
            voidMarks: [],
            bullseyeMarks: [],
            nearMarks: [],
            flats: []
        )
        next.tipsters.append(tipster)
        if next.activeTipsterID == nil {
            next.activeTipsterID = tipster.id
        }
        return Outcome(chart: next, refusal: nil, bullseyeLanded: false)
    }

    static func addFixture(
        homeSide: String,
        awaySide: String,
        kickoffDayKey: Int,
        to chart: BoardChart
    ) -> Outcome {
        let home = homeSide.trimmingCharacters(in: .whitespacesAndNewlines)
        let away = awaySide.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !home.isEmpty, !away.isEmpty else {
            return Outcome(chart: chart, refusal: .emptyName, bullseyeLanded: false)
        }
        guard DayKey.isCalendarDay(kickoffDayKey) else {
            return Outcome(chart: chart, refusal: .invalidDayKey, bullseyeLanded: false)
        }
        var next = chart
        let fixture = Fixture(
            id: UUID(),
            homeSide: home,
            awaySide: away,
            kickoffDayKey: kickoffDayKey,
            finalHome: nil,
            finalAway: nil
        )
        next.fixtures.append(fixture)
        for index in next.tipsters.indices {
            next.tipsters[index].lines.append(
                FixturePhase(fixtureID: fixture.id, phase: .open, cell: nil)
            )
        }
        if next.activeFixtureID == nil {
            next.activeFixtureID = fixture.id
        }
        return Outcome(chart: next, refusal: nil, bullseyeLanded: false)
    }

    static func aim(
        tipsterID: UUID,
        fixtureID: UUID,
        cell: Cell,
        today: Int,
        chart: BoardChart
    ) -> Outcome {
        var next = sweepVoids(today: today, chart: chart)
        guard cell.isOnLattice else {
            return Outcome(chart: next, refusal: .invalidCell, bullseyeLanded: false)
        }
        guard next.fixture(fixtureID) != nil else {
            return Outcome(chart: next, refusal: .unknownFixture, bullseyeLanded: false)
        }
        guard var tipster = next.tipster(tipsterID), var line = tipster.line(for: fixtureID) else {
            return Outcome(chart: next, refusal: .unknownTipster, bullseyeLanded: false)
        }
        switch line.phase {
        case .open:
            line.phase = .aimed
            line.cell = cell
            tipster.aimMarks.append(
                AimMark(id: UUID(), tipsterID: tipsterID, fixtureID: fixtureID, cell: cell)
            )
            tipster.updateLine(line)
            next.replaceTipster(tipster)
            return Outcome(chart: next, refusal: nil, bullseyeLanded: false)
        case .aimed:
            tipster.skewMarks.append(
                SkewMark(id: UUID(), tipsterID: tipsterID, fixtureID: fixtureID, attempted: cell)
            )
            tipster.updateLine(line)
            next.replaceTipster(tipster)
            return Outcome(chart: next, refusal: nil, bullseyeLanded: false)
        case .sealed, .posted, .void:
            return Outcome(chart: next, refusal: .aimRefused, bullseyeLanded: false)
        }
    }

    static func seal(
        tipsterID: UUID,
        fixtureID: UUID,
        today: Int,
        chart: BoardChart
    ) -> Outcome {
        var next = sweepVoids(today: today, chart: chart)
        guard let fixture = next.fixture(fixtureID) else {
            return Outcome(chart: next, refusal: .unknownFixture, bullseyeLanded: false)
        }
        guard var tipster = next.tipster(tipsterID), var line = tipster.line(for: fixtureID) else {
            return Outcome(chart: next, refusal: .unknownTipster, bullseyeLanded: false)
        }
        guard line.phase == .aimed, let cell = line.cell else {
            return Outcome(chart: next, refusal: .notAimed, bullseyeLanded: false)
        }
        guard today < fixture.kickoffDayKey else {
            return Outcome(chart: next, refusal: .sealAfterKickoff, bullseyeLanded: false)
        }
        line.phase = .sealed
        tipster.sealMarks.append(
            SealMark(id: UUID(), tipsterID: tipsterID, fixtureID: fixtureID, cell: cell)
        )
        tipster.updateLine(line)
        next.replaceTipster(tipster)
        return Outcome(chart: next, refusal: nil, bullseyeLanded: false)
    }

    static func peel(
        tipsterID: UUID,
        fixtureID: UUID,
        today: Int,
        chart: BoardChart
    ) -> Outcome {
        var next = sweepVoids(today: today, chart: chart)
        guard let fixture = next.fixture(fixtureID) else {
            return Outcome(chart: next, refusal: .unknownFixture, bullseyeLanded: false)
        }
        guard today < fixture.kickoffDayKey else {
            return Outcome(chart: next, refusal: .peelRefused, bullseyeLanded: false)
        }
        guard var tipster = next.tipster(tipsterID), var line = tipster.line(for: fixtureID) else {
            return Outcome(chart: next, refusal: .unknownTipster, bullseyeLanded: false)
        }
        switch line.phase {
        case .sealed:
            if let index = tipster.sealMarks.lastIndex(where: { $0.fixtureID == fixtureID }) {
                tipster.sealMarks.remove(at: index)
            }
            line.phase = .aimed
            tipster.updateLine(line)
            next.replaceTipster(tipster)
            return Outcome(chart: next, refusal: nil, bullseyeLanded: false)
        case .aimed:
            if let index = tipster.aimMarks.lastIndex(where: { $0.fixtureID == fixtureID }) {
                tipster.aimMarks.remove(at: index)
            }
            line.phase = .open
            line.cell = nil
            tipster.updateLine(line)
            next.replaceTipster(tipster)
            return Outcome(chart: next, refusal: nil, bullseyeLanded: false)
        case .open, .posted, .void:
            return Outcome(chart: next, refusal: .peelRefused, bullseyeLanded: false)
        }
    }

    static func post(
        fixtureID: UUID,
        finalHome: Int,
        finalAway: Int,
        today: Int,
        chart: BoardChart
    ) -> Outcome {
        var next = sweepVoids(today: today, chart: chart)
        guard var fixture = next.fixture(fixtureID) else {
            return Outcome(chart: next, refusal: .unknownFixture, bullseyeLanded: false)
        }
        guard finalHome >= 0, finalAway >= 0 else {
            return Outcome(chart: next, refusal: .negativeScore, bullseyeLanded: false)
        }
        guard today >= fixture.kickoffDayKey else {
            return Outcome(chart: next, refusal: .postBeforeKickoff, bullseyeLanded: false)
        }
        fixture.finalHome = finalHome
        fixture.finalAway = finalAway
        next.replaceFixture(fixture)
        let finalWinner = ScoreWinner.decide(home: finalHome, away: finalAway)
        var landed = false
        for index in next.tipsters.indices {
            guard var line = next.tipsters[index].line(for: fixtureID),
                  line.phase == .sealed,
                  let cell = line.cell else { continue }
            line.phase = .posted
            let tipsterID = next.tipsters[index].id
            let exact = cell.home == finalHome && cell.away == finalAway
            let sameWinner = cell.winner == finalWinner
            let knowledge = score(correct: exact || sameWinner, confidence: 0)
            if exact && knowledge > 0 {
                next.tipsters[index].bullseyeMarks.append(
                    BullseyeMark(id: UUID(), tipsterID: tipsterID, fixtureID: fixtureID, cell: cell)
                )
                landed = true
            } else if sameWinner && knowledge > 0 {
                next.tipsters[index].nearMarks.append(
                    NearMark(id: UUID(), tipsterID: tipsterID, fixtureID: fixtureID, cell: cell)
                )
            } else {
                next.tipsters[index].flats.append(
                    Flat(id: UUID(), tipsterID: tipsterID, fixtureID: fixtureID, cell: cell)
                )
            }
            next.tipsters[index].updateLine(line)
        }
        return Outcome(chart: next, refusal: nil, bullseyeLanded: landed)
    }

    /// Open or Aimed fixtures whose kickoff day has arrived fold to Void.
    static func sweepVoids(today: Int, chart: BoardChart) -> BoardChart {
        var next = chart
        for fixture in next.fixtures where today >= fixture.kickoffDayKey {
            for index in next.tipsters.indices {
                guard var line = next.tipsters[index].line(for: fixture.id) else { continue }
                guard line.phase == .open || line.phase == .aimed else { continue }
                line.phase = .void
                next.tipsters[index].voidMarks.append(
                    VoidMark(id: UUID(), tipsterID: next.tipsters[index].id, fixtureID: fixture.id)
                )
                next.tipsters[index].updateLine(line)
            }
        }
        return next
    }

    /// Drops aimed cells, seals, and posted points. Fixtures and names stay.
    static func resetRound(_ chart: BoardChart) -> BoardChart {
        var next = chart
        for index in next.tipsters.indices {
            next.tipsters[index].aimMarks = []
            next.tipsters[index].sealMarks = []
            next.tipsters[index].skewMarks = []
            next.tipsters[index].voidMarks = []
            next.tipsters[index].bullseyeMarks = []
            next.tipsters[index].nearMarks = []
            next.tipsters[index].flats = []
            next.tipsters[index].lines = next.tipsters[index].lines.map { line in
                FixturePhase(fixtureID: line.fixtureID, phase: .open, cell: nil)
            }
        }
        for index in next.fixtures.indices {
            next.fixtures[index].finalHome = nil
            next.fixtures[index].finalAway = nil
        }
        return next
    }
}
