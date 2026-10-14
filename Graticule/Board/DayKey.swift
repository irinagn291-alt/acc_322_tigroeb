import Foundation

/// Turns a calendar day into the YYYYMMDD integer the board folds on.
enum DayKey {
    static func from(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func today(calendar: Calendar = .current, now: Date = Date()) -> Int {
        from(now, calendar: calendar)
    }

    /// Shifts a daykey by whole calendar days, still passing through startOfDay.
    static func adding(days: Int, to dayKey: Int, calendar: Calendar = .current) -> Int {
        var parts = DateComponents()
        parts.year = dayKey / 10_000
        parts.month = (dayKey / 100) % 100
        parts.day = dayKey % 100
        guard let date = calendar.date(from: parts),
              let shifted = calendar.date(byAdding: .day, value: days, to: date) else {
            return dayKey
        }
        return from(shifted, calendar: calendar)
    }

    /// True when the integer is a real calendar day in YYYYMMDD form.
    static func isCalendarDay(_ dayKey: Int, calendar: Calendar = .current) -> Bool {
        let year = dayKey / 10_000
        let month = (dayKey / 100) % 100
        let day = dayKey % 100
        guard year >= 1, (1...12).contains(month), (1...31).contains(day) else { return false }
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        parts.calendar = calendar
        guard let date = calendar.date(from: parts) else { return false }
        return from(date, calendar: calendar) == dayKey
    }
}
