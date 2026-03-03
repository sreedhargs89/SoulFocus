// Streak+Extensions.swift
// Computed helpers on the Streak entity.

import CoreData
import Foundation

extension Streak {

    // MARK: - Display Helpers

    /// Formatted total meditation time, e.g. "10 hr 30 min"
    var formattedTotalTime: String {
        let totalSeconds = Int(totalMeditationSeconds)
        let hours   = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 { return "\(hours) hr \(minutes) min" }
        return "\(minutes) min"
    }

    /// Average session duration in minutes, rounded to nearest minute.
    var averageSessionMinutes: Int {
        guard totalSessionCount > 0 else { return 0 }
        return Int(totalMeditationSeconds) / Int(totalSessionCount) / 60
    }

    /// Whether the user has practiced today.
    var practicedToday: Bool {
        guard let last = lastSessionDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    /// Number of days since the streak started.
    var totalDaysActive: Int {
        guard let start = startDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
    }

    /// Motivational label based on current streak length.
    var streakBadgeLabel: String {
        switch currentStreak {
        case 0:         return "Start your streak today"
        case 1:         return "Day 1 — great start!"
        case 2...6:     return "\(currentStreak) days — keep going!"
        case 7...13:    return "One week strong 🔥"
        case 14...29:   return "Two weeks! You're consistent"
        case 30...:     return "\(currentStreak) days — extraordinary!"
        default:        return "\(currentStreak) day streak"
        }
    }
}
