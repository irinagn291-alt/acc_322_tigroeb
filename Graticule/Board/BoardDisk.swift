import Foundation
import os

/// Atomic file projection of the in-memory chart. The main actor never calls this inline.
enum BoardDisk {
    static let fileName = "board.json"
    static let backupName = "board.json.backup"

    enum ReadResult: Sendable {
        case chart(BoardChart)
        case unreadable
        case missing
    }

    /// Names the Application Support folder. Creation happens inside `write`, off the main actor.
    static func supportDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return base.appendingPathComponent("Tigroeb", isDirectory: true)
    }

    /// Writes off the caller. Previous good bytes are kept as a backup first.
    static func write(_ data: Data, directory: URL) async throws {
        try await Task.detached(priority: .utility) {
            // File IO stays off the main actor so a save cannot stall the board.
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let primary = directory.appendingPathComponent(fileName)
            let backup = directory.appendingPathComponent(backupName)
            if FileManager.default.fileExists(atPath: primary.path) {
                if FileManager.default.fileExists(atPath: backup.path) {
                    try FileManager.default.removeItem(at: backup)
                }
                try FileManager.default.copyItem(at: primary, to: backup)
            }
            try data.write(to: primary, options: .atomic)
        }.value
    }

    static func read(directory: URL) async -> ReadResult {
        await Task.detached(priority: .utility) {
            // File IO stays off the main actor.
            let primary = directory.appendingPathComponent(fileName)
            let backup = directory.appendingPathComponent(backupName)
            if let chart = decodeFile(at: primary) {
                return .chart(chart)
            }
            let primaryExists = FileManager.default.fileExists(atPath: primary.path)
            if let chart = decodeFile(at: backup) {
                return .chart(chart)
            }
            if primaryExists || FileManager.default.fileExists(atPath: backup.path) {
                return .unreadable
            }
            return .missing
        }.value
    }

    static func removeAll(directory: URL) async {
        await Task.detached(priority: .utility) {
            let primary = directory.appendingPathComponent(fileName)
            let backup = directory.appendingPathComponent(backupName)
            if FileManager.default.fileExists(atPath: primary.path) {
                do {
                    try FileManager.default.removeItem(at: primary)
                } catch {
                    Logger.board.error("Could not delete board file: \(error.localizedDescription, privacy: .public)")
                }
            }
            if FileManager.default.fileExists(atPath: backup.path) {
                do {
                    try FileManager.default.removeItem(at: backup)
                } catch {
                    Logger.board.error("Could not delete board backup: \(error.localizedDescription, privacy: .public)")
                }
            }
        }.value
    }

    private static func decodeFile(at url: URL) -> BoardChart? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? BoardCoding.decode(data)
    }
}

private extension Logger {
    static let board = Logger(subsystem: "com.graticule.lattice", category: "board-disk")
}

enum BoardCoding {
    static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }

    static func encode(_ chart: BoardChart) throws -> Data {
        try encoder().encode(chart)
    }

    static func decode(_ data: Data) throws -> BoardChart {
        try decoder().decode(BoardChart.self, from: data)
    }
}
