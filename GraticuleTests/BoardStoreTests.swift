import XCTest
@testable import Graticule

@MainActor
final class BoardStoreTests: XCTestCase {
    func testRoundTripReload() async throws {
        let suite = "grc.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await store.waitUntilReady()
        let added = store.addFixture(homeSide: "Milltown", awaySide: "Harbor", kickoffDayKey: 20261004)
        XCTAssertNil(added.refusal)
        _ = store.addTipster(name: "Ada Quinn")
        let fixture = try XCTUnwrap(store.chart.fixtures.first?.id)
        let tipster = try XCTUnwrap(store.chart.tipsters.first?.id)
        let aimed = store.aim(tipsterID: tipster, fixtureID: fixture, cell: Cell(home: 1, away: 0), today: 20260927)
        XCTAssertNil(aimed.refusal)
        await store.flush()

        let reloaded = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await reloaded.waitUntilReady()
        XCTAssertEqual(reloaded.chart.fixtures.count, 1)
        XCTAssertEqual(reloaded.chart.tipsters.first?.line(for: fixture)?.phase, .aimed)
        XCTAssertEqual(reloaded.chart.tipsters.first?.line(for: fixture)?.cell, Cell(home: 1, away: 0))
        XCTAssertNil(reloaded.loadNotice)
        defaults.removePersistentDomain(forName: suite)
    }

    func testCorruptChartBecomesBlankWithNotice() async throws {
        let suite = "grc.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        defaults.set(Data("not-json".utf8), forKey: BoardStore.storageKey)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await store.waitUntilReady()
        XCTAssertTrue(store.chart.isBlank)
        XCTAssertEqual(store.loadNotice, BoardStore.unreadableNotice)
        defaults.removePersistentDomain(forName: suite)
    }

    func testResetAllDataDeletesTheKey() async throws {
        let suite = "grc.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await store.waitUntilReady()
        _ = store.addTipster(name: "Ben Holt")
        await store.flush()
        XCTAssertNotNil(defaults.data(forKey: BoardStore.storageKey))
        await store.resetAllData()
        XCTAssertNil(defaults.data(forKey: BoardStore.storageKey))
        XCTAssertTrue(store.chart.isBlank)
        let primary = directory.appendingPathComponent(BoardDisk.fileName)
        XCTAssertFalse(FileManager.default.fileExists(atPath: primary.path))
        defaults.removePersistentDomain(forName: suite)
    }

    func testFileBackupRestoresAfterACorruptPrimary() async throws {
        let suite = "grc.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await store.waitUntilReady()
        _ = store.addTipster(name: "Cora Voss")
        await store.flush()
        _ = store.addTipster(name: "Ada Quinn")
        await store.flush()
        defaults.removeObject(forKey: BoardStore.storageKey)
        let primary = directory.appendingPathComponent(BoardDisk.fileName)
        try Data("broken".utf8).write(to: primary, options: .atomic)
        let recovered = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await recovered.waitUntilReady()
        XCTAssertEqual(recovered.chart.tipsters.map(\.name), ["Cora Voss"])
        XCTAssertNil(recovered.loadNotice)
        defaults.removePersistentDomain(forName: suite)
    }

    func testRefusedKickoffKeepsTheVoidMark() async throws {
        let suite = "grc.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await store.waitUntilReady()
        let kickoff = 20260920
        _ = store.addFixture(homeSide: "Milltown", awaySide: "Harbor", kickoffDayKey: kickoff)
        _ = store.addTipster(name: "Ada Quinn")
        let fixture = try XCTUnwrap(store.chart.fixtures.first?.id)
        let tipster = try XCTUnwrap(store.chart.tipsters.first?.id)
        let aimed = store.aim(tipsterID: tipster, fixtureID: fixture, cell: Cell(home: 1, away: 0), today: 20260901)
        XCTAssertNil(aimed.refusal)
        let seal = store.seal(tipsterID: tipster, fixtureID: fixture, today: kickoff)
        XCTAssertNotNil(seal.refusal)
        XCTAssertEqual(store.chart.tipsters[0].line(for: fixture)?.phase, .void)
        XCTAssertEqual(store.chart.tipsters[0].voidMarks.count, 1)
        let peeled = store.peel(tipsterID: tipster, fixtureID: fixture, today: kickoff)
        XCTAssertNotNil(peeled.refusal)
        XCTAssertEqual(store.chart.tipsters[0].line(for: fixture)?.phase, .void)
        let posted = store.post(fixtureID: fixture, finalHome: -1, finalAway: 0, today: kickoff)
        XCTAssertEqual(posted.refusal, .negativeScore)
        XCTAssertEqual(store.chart.tipsters[0].voidMarks.count, 1)
        defaults.removePersistentDomain(forName: suite)
    }

    func testOpenKickoffAimKeepsVoid() async throws {
        let suite = "grc.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await store.waitUntilReady()
        let kickoff = 20260920
        _ = store.addFixture(homeSide: "Loom End", awaySide: "Kiln Row", kickoffDayKey: kickoff)
        _ = store.addTipster(name: "Ben Holt")
        let fixture = try XCTUnwrap(store.chart.fixtures.first?.id)
        let tipster = try XCTUnwrap(store.chart.tipsters.first?.id)
        let aimed = store.aim(tipsterID: tipster, fixtureID: fixture, cell: Cell(home: 2, away: 1), today: kickoff)
        XCTAssertNotNil(aimed.refusal)
        XCTAssertEqual(store.chart.tipsters[0].line(for: fixture)?.phase, .void)
        XCTAssertEqual(store.chart.tipsters[0].voidMarks.count, 1)
        XCTAssertNil(store.chart.tipsters[0].line(for: fixture)?.cell)
        defaults.removePersistentDomain(forName: suite)
    }

    func testSceneLeftActiveWritesBeforeTheDebounce() async throws {
        let suite = "grc.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = BoardStore(defaults: defaults, directory: directory, seedOnSimulator: false)
        await store.waitUntilReady()
        _ = store.addTipster(name: "Cora Voss")
        XCTAssertNil(defaults.data(forKey: BoardStore.storageKey))
        await store.sceneLeftActive()
        XCTAssertNotNil(defaults.data(forKey: BoardStore.storageKey))
        defaults.removePersistentDomain(forName: suite)
    }
}
