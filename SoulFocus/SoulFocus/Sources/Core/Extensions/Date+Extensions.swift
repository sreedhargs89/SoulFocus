// Date+Extensions.swift
// Date helpers used throughout the app.

import Foundation

extension Date {

    // MARK: - Calendar Shortcuts

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Returns a Date `days` days before self.
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }

    // MARK: - Formatting

    /// "Monday, 3 March"
    var fullDateString: String {
        formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    /// "3 Mar" — compact for charts and calendars
    var shortDateString: String {
        formatted(.dateTime.day().month(.abbreviated))
    }

    /// "08:30 AM"
    var timeString: String {
        formatted(.dateTime.hour().minute())
    }

    // MARK: - Streak Helpers

    /// True if self and `other` fall on the same calendar day.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// True if self is exactly one calendar day before `other`.
    func isDayBefore(_ other: Date) -> Bool {
        let selfDay  = Calendar.current.startOfDay(for: self)
        let otherDay = Calendar.current.startOfDay(for: other)
        return Calendar.current.dateComponents([.day], from: selfDay, to: otherDay).day == 1
    }
}

// MARK: - TimeInterval Helpers

extension TimeInterval {

    /// "10 min" or "1 hr 5 min"
    var durationString: String {
        let total   = Int(self)
        let hours   = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0   { return "\(hours) hr \(minutes) min" }
        if minutes > 0 { return "\(minutes) min" }
        return "\(seconds) sec"
    }

    /// MM:SS format for the session countdown timer
    var timerString: String {
        let total   = Int(self)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
