import XCTest
@testable import Graticule

final class BoardFoldTests: XCTestCase {
    private let today = 20260927
    private let kickoff = 20261004

    func testEmptyBoardIsBlank() {
        let chart = BoardChart.blank()
        XCTAssertTrue(chart.isBlank)
        XCTAssertTrue(BoardFold.standings(in: chart).isEmpty)
    }

    func testAimRejectsACellOffTheLattice() {
        let named = BoardFold.addTipster(name: "Ada Quinn", to: .blank())
        let open = BoardFold.addFixture(
            homeSide: "Milltown",
            awaySide: "Harbor",
            kickoffDayKey: kickoff,
            to: named.chart
        ).chart
        let tipster = open.tipsters[0].id
        let fixture = open.fixtures[0].id
        let outcome = BoardFold.aim(
            tipsterID: tipster,
            fixtureID: fixture,
            cell: Cell(home: 4, away: 1),
            today: today,
            chart: open
        )
        XCTAssertEqual(outcome.refusal, .invalidCell)
        XCTAssertEqual(outcome.chart.tipsters[0].line(for: fixture)?.phase, .open)
        XCTAssertNil(outcome.chart.tipsters[0].line(for: fixture)?.cell)
    }

    func testAimThenSealBeforeKickoff() {
        let seeded = aimedChart()
        XCTAssertNil(seeded.refusal)
        let tipster = seeded.chart.tipsters[0].id
        let fixture = seeded.chart.fixtures[0].id
        XCTAssertEqual(seeded.chart.tipsters[0].line(for: fixture)?.phase, .aimed)
        XCTAssertEqual(seeded.chart.tipsters[0].line(for: fixture)?.cell, Cell(home: 2, away: 1))
        let sealed = BoardFold.seal(tipsterID: tipster, fixtureID: fixture, today: today, chart: seeded.chart)
        XCTAssertNil(sealed.refusal)
        XCTAssertEqual(sealed.chart.tipsters[0].line(for: fixture)?.phase, .sealed)
        XCTAssertEqual(sealed.chart.tipsters[0].sealMarks.count, 1)
    }

    func testSecondAimWritesSkewAndKeepsTheCell() {
        let seeded = aimedChart()
        let tipster = seeded.chart.tipsters[0].id
        let fixture = seeded.chart.fixtures[0].id
        let again = BoardFold.aim(
            tipsterID: tipster,
            fixtureID: fixture,
            cell: Cell(home: 0, away: 0),
            today: today,
            chart: seeded.chart
        )
        XCTAssertNil(again.refusal)
        XCTAssertEqual(again.chart.tipsters[0].line(for: fixture)?.cell, Cell(home: 2, away: 1))
        XCTAssertEqual(again.chart.tipsters[0].skewMarks.count, 1)
        XCTAssertEqual(again.chart.tipsters[0].line(for: fixture)?.phase, .aimed)
    }

    func testAimOnSealedIsRefused() {
        let sealed = sealedChart()
        let tipster = sealed.tipsters[0].id
        let fixture = sealed.fixtures[0].id
        let outcome = BoardFold.aim(
            tipsterID: tipster,
            fixtureID: fixture,
            cell: Cell(home: 3, away: 3),
            today: today,
            chart: sealed
        )
        XCTAssertEqual(outcome.refusal, .aimRefused)
        XCTAssertEqual(outcome.chart.tipsters[0].line(for: fixture)?.phase, .sealed)
    }

    func testKickoffWithoutSealWritesVoid() {
        let seeded = aimedChart().chart
        let swept = BoardFold.sweepVoids(today: kickoff, chart: seeded)
        let fixture = seeded.fixtures[0].id
        XCTAssertEqual(swept.tipsters[0].line(for: fixture)?.phase, .void)
        XCTAssertEqual(swept.tipsters[0].voidMarks.count, 1)
        let seal = BoardFold.seal(
            tipsterID: seeded.tipsters[0].id,
            fixtureID: fixture,
            today: kickoff,
            chart: seeded
        )
        XCTAssertEqual(seal.chart.tipsters[0].line(for: fixture)?.phase, .void)
    }

    func testOneCellPerTipsterAndSealBeforePost() {
        var chart = sealedChart()
        let fixture = chart.fixtures[0].id
        XCTAssertEqual(chart.tipsters[0].sealMarks.filter { $0.fixtureID == fixture }.count, 1)
        let early = BoardFold.post(
            fixtureID: fixture,
            finalHome: 2,
            finalAway: 1,
            today: today,
            chart: chart
        )
        XCTAssertEqual(early.refusal, .postBeforeKickoff)
        let posted = BoardFold.post(
            fixtureID: fixture,
            finalHome: 2,
            finalAway: 1,
            today: kickoff,
            chart: chart
        )
        XCTAssertNil(posted.refusal)
        XCTAssertTrue(posted.bullseyeLanded)
        XCTAssertEqual(posted.chart.tipsters[0].line(for: fixture)?.phase, .posted)
        XCTAssertEqual(BoardFold.standings(in: posted.chart)[0].points, BullseyeMark.points)
        chart = posted.chart
        let second = BoardFold.aim(
            tipsterID: chart.tipsters[0].id,
            fixtureID: fixture,
            cell: Cell(home: 1, away: 0),
            today: kickoff,
            chart: chart
        )
        XCTAssertEqual(second.refusal, .aimRefused)
    }

    func testBullseyeNearAndFlatFromTypedScores() {
        let bullseye = post(finalHome: 2, finalAway: 1, cell: Cell(home: 2, away: 1))
        XCTAssertEqual(bullseye.tipsters[0].bullseyeMarks.count, 1)
        XCTAssertEqual(BoardFold.standings(in: bullseye)[0].points, 9)

        let near = post(finalHome: 3, finalAway: 0, cell: Cell(home: 2, away: 1))
        XCTAssertEqual(near.tipsters[0].nearMarks.count, 1)
        XCTAssertEqual(BoardFold.standings(in: near)[0].points, 3)

        let flat = post(finalHome: 0, finalAway: 2, cell: Cell(home: 2, away: 1))
        XCTAssertEqual(flat.tipsters[0].flats.count, 1)
        XCTAssertEqual(BoardFold.standings(in: flat)[0].points, 0)
    }

    func testNegativeScoreIsRefused() {
        let chart = sealedChart()
        let outcome = BoardFold.post(
            fixtureID: chart.fixtures[0].id,
            finalHome: -1,
            finalAway: 0,
            today: kickoff,
            chart: chart
        )
        XCTAssertEqual(outcome.refusal, .negativeScore)
    }

    func testPeelDropsSealThenAimBeforeKickoff() {
        let sealed = sealedChart()
        let tipster = sealed.tipsters[0].id
        let fixture = sealed.fixtures[0].id
        let peeled = BoardFold.peel(tipsterID: tipster, fixtureID: fixture, today: today, chart: sealed)
        XCTAssertEqual(peeled.chart.tipsters[0].line(for: fixture)?.phase, .aimed)
        XCTAssertTrue(peeled.chart.tipsters[0].sealMarks.isEmpty)
        let opened = BoardFold.peel(tipsterID: tipster, fixtureID: fixture, today: today, chart: peeled.chart)
        XCTAssertEqual(opened.chart.tipsters[0].line(for: fixture)?.phase, .open)
        XCTAssertNil(opened.chart.tipsters[0].line(for: fixture)?.cell)
    }

    func testFoldWalksOpenAimedSealedPosted() {
        let aimed = aimedChart()
        XCTAssertEqual(aimed.chart.tipsters[0].lines[0].phase, .aimed)
        let sealed = BoardFold.seal(
            tipsterID: aimed.chart.tipsters[0].id,
            fixtureID: aimed.chart.fixtures[0].id,
            today: today,
            chart: aimed.chart
        )
        XCTAssertEqual(sealed.chart.tipsters[0].lines[0].phase, .sealed)
        let posted = BoardFold.post(
            fixtureID: sealed.chart.fixtures[0].id,
            finalHome: 1,
            finalAway: 1,
            today: kickoff,
            chart: sealed.chart
        )
        XCTAssertEqual(posted.chart.tipsters[0].lines[0].phase, .posted)
        XCTAssertEqual(posted.chart.tipsters[0].flats.count, 1)
    }

    func testFamilyScoreUsesConfidenceOnlyWhenThePickIsCorrect() {
        // Score = 100 × (1 + confidence/100) if correct, else 0. Not RNG.
        XCTAssertEqual(BoardFold.score(correct: true, confidence: 100), 200)
        XCTAssertEqual(BoardFold.score(correct: true, confidence: 0), 100)
        XCTAssertEqual(BoardFold.score(correct: false, confidence: 80), 0)
        let bullseye = post(finalHome: 2, finalAway: 1, cell: Cell(home: 2, away: 1))
        XCTAssertEqual(BoardFold.postedPoints(for: bullseye.tipsters[0]), BullseyeMark.points)
        XCTAssertGreaterThan(BoardFold.score(correct: true, confidence: 0), 0)
    }

    func testDemoSeedOpensOnMilltownWithSealReady() {
        let chart = DemoSeed.chart(today: today)
        XCTAssertTrue(chart.onboardingComplete)
        XCTAssertEqual(chart.fixtures.first?.homeSide, "Milltown")
        XCTAssertEqual(chart.activeFixtureID, chart.fixtures.first?.id)
        let ada = chart.tipsters[0]
        XCTAssertEqual(ada.name, "Ada Quinn")
        XCTAssertEqual(ada.line(for: chart.fixtures[0].id)?.phase, .aimed)
        XCTAssertEqual(ada.line(for: chart.fixtures[0].id)?.cell, Cell(home: 2, away: 1))
        let points = BoardFold.standings(in: chart).map(\.points)
        XCTAssertEqual(points, [9, 3, 0])
    }

    func testInvalidDayKeyIsRefused() {
        let named = BoardFold.addTipster(name: "Ada Quinn", to: .blank())
        let outcome = BoardFold.addFixture(
            homeSide: "Milltown",
            awaySide: "Harbor",
            kickoffDayKey: 20260231,
            to: named.chart
        )
        XCTAssertEqual(outcome.refusal, .invalidDayKey)
        XCTAssertTrue(outcome.chart.fixtures.isEmpty)
        XCTAssertFalse(DayKey.isCalendarDay(20261340))
        XCTAssertTrue(DayKey.isCalendarDay(kickoff))
    }

    func testDayKeyUsesStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let evening = Date(timeIntervalSince1970: 1_800_000_000)
        let key = DayKey.from(evening, calendar: calendar)
        let start = calendar.startOfDay(for: evening)
        XCTAssertEqual(key, DayKey.from(start, calendar: calendar))
        XCTAssertGreaterThan(key, 20200101)
    }

    private func aimedChart() -> BoardFold.Outcome {
        let named = BoardFold.addTipster(name: "Ada Quinn", to: .blank())
        let withFixture = BoardFold.addFixture(
            homeSide: "Milltown",
            awaySide: "Harbor",
            kickoffDayKey: kickoff,
            to: named.chart
        )
        return BoardFold.aim(
            tipsterID: withFixture.chart.tipsters[0].id,
            fixtureID: withFixture.chart.fixtures[0].id,
            cell: Cell(home: 2, away: 1),
            today: today,
            chart: withFixture.chart
        )
    }

    private func sealedChart() -> BoardChart {
        let aimed = aimedChart().chart
        return BoardFold.seal(
            tipsterID: aimed.tipsters[0].id,
            fixtureID: aimed.fixtures[0].id,
            today: today,
            chart: aimed
        ).chart
    }

    private func post(finalHome: Int, finalAway: Int, cell: Cell) -> BoardChart {
        let named = BoardFold.addTipster(name: "Ada Quinn", to: .blank())
        let withFixture = BoardFold.addFixture(
            homeSide: "Milltown",
            awaySide: "Harbor",
            kickoffDayKey: kickoff,
            to: named.chart
        ).chart
        let aimed = BoardFold.aim(
            tipsterID: withFixture.tipsters[0].id,
            fixtureID: withFixture.fixtures[0].id,
            cell: cell,
            today: today,
            chart: withFixture
        ).chart
        let sealed = BoardFold.seal(
            tipsterID: aimed.tipsters[0].id,
            fixtureID: aimed.fixtures[0].id,
            today: today,
            chart: aimed
        ).chart
        return BoardFold.post(
            fixtureID: sealed.fixtures[0].id,
            finalHome: finalHome,
            finalAway: finalAway,
            today: kickoff,
            chart: sealed
        ).chart
    }
}
