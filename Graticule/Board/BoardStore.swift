import Foundation
import os

/// In-memory source of truth. Screens talk only to this type.
/// The chart file and the UserDefaults blob are projections of `chart`.
@MainActor
final class BoardStore {
    static let storageKey = "grc.chart.v1"
    static let unreadableNotice = "The saved board could not be read."
    static let debounceNanoseconds: UInt64 = 400_000_000

    private let defaults: UserDefaults
    private let directory: URL
    private let debounce = DebouncedWork()
    private var generation = 0
    private var flushRunning = false
    private var flushAgain = false
    private var launchTask: Task<Void, Never>?
    private var ignoreDiskRecovery = false

    private(set) var chart: BoardChart
    private(set) var loadNotice: String?
    private(set) var isReady = false

    init(defaults: UserDefaults, directory: URL, seedOnSimulator: Bool) {
        self.defaults = defaults
        self.directory = directory
        if let data = defaults.data(forKey: Self.storageKey) {
            if let decoded = try? BoardCoding.decode(data) {
                chart = decoded
                isReady = true
            } else {
                chart = .blank()
                loadNotice = Self.unreadableNotice
                launchTask = Task { [weak self] in
                    await self?.recoverFromDisk(replaceNotice: true)
                }
            }
        } else {
            chart = .blank()
            launchTask = Task { [weak self] in
                await self?.recoverFromDisk(replaceNotice: false)
            }
        }
        if seedOnSimulator {
            let today = DayKey.today()
            if DemoSeed.applyIfNeeded(to: &chart, defaults: defaults, today: today) {
                loadNotice = nil
                isReady = true
                ignoreDiskRecovery = true
                scheduleSave()
            }
        }
    }

    /// Waits until a disk fallback, if any, has finished.
    func waitUntilReady() async {
        await launchTask?.value
        isReady = true
    }

    static func live() -> BoardStore {
        let directory = BoardDisk.supportDirectory()
        let seed: Bool
        #if targetEnvironment(simulator)
        seed = true
        #else
        seed = false
        #endif
        return BoardStore(defaults: .standard, directory: directory, seedOnSimulator: seed)
    }

    func standings() -> [Standing] {
        BoardFold.standings(in: chart)
    }

    @discardableResult
    func aim(tipsterID: UUID, fixtureID: UUID, cell: Cell, today: Int) -> BoardFold.Outcome {
        apply(BoardFold.aim(tipsterID: tipsterID, fixtureID: fixtureID, cell: cell, today: today, chart: chart))
    }

    @discardableResult
    func seal(tipsterID: UUID, fixtureID: UUID, today: Int) -> BoardFold.Outcome {
        apply(BoardFold.seal(tipsterID: tipsterID, fixtureID: fixtureID, today: today, chart: chart))
    }

    @discardableResult
    func peel(tipsterID: UUID, fixtureID: UUID, today: Int) -> BoardFold.Outcome {
        apply(BoardFold.peel(tipsterID: tipsterID, fixtureID: fixtureID, today: today, chart: chart))
    }

    @discardableResult
    func post(fixtureID: UUID, finalHome: Int, finalAway: Int, today: Int) -> BoardFold.Outcome {
        apply(BoardFold.post(fixtureID: fixtureID, finalHome: finalHome, finalAway: finalAway, today: today, chart: chart))
    }

    @discardableResult
    func addFixture(homeSide: String, awaySide: String, kickoffDayKey: Int) -> BoardFold.Outcome {
        apply(BoardFold.addFixture(homeSide: homeSide, awaySide: awaySide, kickoffDayKey: kickoffDayKey, to: chart))
    }

    @discardableResult
    func addTipster(name: String) -> BoardFold.Outcome {
        apply(BoardFold.addTipster(name: name, to: chart))
    }

    func resetRound() {
        chart = BoardFold.resetRound(chart)
        scheduleSave()
    }

    /// Folds unsealed fixtures whose kickoff day has arrived.
    func foldToday(_ today: Int) {
        let next = BoardFold.sweepVoids(today: today, chart: chart)
        guard next != chart else { return }
        chart = next
        scheduleSave()
    }

    func selectFixture(_ id: UUID) {
        guard chart.fixture(id) != nil else { return }
        chart.activeFixtureID = id
        scheduleSave()
    }

    func selectTipster(_ id: UUID) {
        guard chart.tipster(id) != nil else { return }
        chart.activeTipsterID = id
        scheduleSave()
    }

    func renameTipster(_ id: UUID, name: String) -> BoardFold.Refusal? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .emptyName }
        guard var tipster = chart.tipster(id) else { return .unknownTipster }
        tipster.name = trimmed
        chart.replaceTipster(tipster)
        scheduleSave()
        return nil
    }

    func markOnboardingComplete() {
        guard chart.onboardingComplete == false else { return }
        chart.onboardingComplete = true
        scheduleSave()
    }

    func reopenOnboarding() {
        chart.onboardingComplete = false
        scheduleSave()
    }

    /// Deletes the chart key and the file. Used by tests and Settings.
    func resetAllData() async {
        debounce.cancel()
        generation += 1
        defaults.removeObject(forKey: Self.storageKey)
        defaults.removeObject(forKey: DemoSeed.defaultsKey)
        await BoardDisk.removeAll(directory: directory)
        chart = .blank()
        loadNotice = nil
    }

    /// Scene left the active state. Flush so a force-quit keeps the write.
    func sceneLeftActive() async {
        await flush()
        while flushRunning {
            await Task.yield()
        }
    }

    func scheduleSave() {
        generation += 1
        let token = generation
        debounce.schedule(afterNanoseconds: Self.debounceNanoseconds) { [weak self] in
            await self?.flush(ifGeneration: token)
        }
    }

    func flush() async {
        generation += 1
        await flush(ifGeneration: generation)
    }

    private func apply(_ outcome: BoardFold.Outcome) -> BoardFold.Outcome {
        let voidSweep = outcome.refusal != nil && outcome.chart != chart
        guard outcome.refusal == nil || voidSweep else { return outcome }
        chart = outcome.chart
        scheduleSave()
        return outcome
    }

    private func flush(ifGeneration token: Int) async {
        guard token == generation else { return }
        if flushRunning {
            flushAgain = true
            return
        }
        flushRunning = true
        defer { flushRunning = false }
        repeat {
            flushAgain = false
            let snapshot = chart
            let writtenToken = generation
            guard let data = try? BoardCoding.encode(snapshot) else {
                loadNotice = Self.unreadableNotice
                return
            }
            defaults.set(data, forKey: Self.storageKey)
            do {
                try await BoardDisk.write(data, directory: directory)
            } catch {
                Logger.board.error("Board file save failed: \(error.localizedDescription, privacy: .public)")
            }
            if writtenToken != generation {
                flushAgain = true
            }
        } while flushAgain
    }

    private func recoverFromDisk(replaceNotice: Bool) async {
        if ignoreDiskRecovery { return }
        let result = await BoardDisk.read(directory: directory)
        if ignoreDiskRecovery { return }
        switch result {
        case .chart(let recovered):
            if defaults.data(forKey: Self.storageKey) == nil || replaceNotice {
                chart = recovered
                if let data = try? BoardCoding.encode(recovered) {
                    defaults.set(data, forKey: Self.storageKey)
                }
                if !replaceNotice {
                    loadNotice = nil
                }
            }
        case .unreadable:
            chart = .blank()
            loadNotice = Self.unreadableNotice
        case .missing:
            if replaceNotice {
                chart = .blank()
                loadNotice = Self.unreadableNotice
            }
        }
        isReady = true
    }
}

private extension Logger {
    static let board = Logger(subsystem: "com.graticule.lattice", category: "board")
}

/// Owns the pending save task so a newer mark cancels the in-flight wait.
final class DebouncedWork: Sendable {
    private let state = OSAllocatedUnfairLock<Task<Void, Never>?>(initialState: nil)

    func schedule(afterNanoseconds delay: UInt64, _ body: @escaping @Sendable () async -> Void) {
        let task = Task {
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            await body()
        }
        state.withLock { current in
            current?.cancel()
            current = task
        }
    }

    func cancel() {
        state.withLock { current in
            current?.cancel()
            current = nil
        }
    }
}
