// MeditationSession+Extensions.swift
// Computed helpers on the auto-generated NSManagedObject subclass.

import CoreData
import Foundation

extension MeditationSession {

    // MARK: - Computed

    /// Human-readable duration string, e.g. "10 min" or "1 hr 5 min"
    var formattedDuration: String {
        let seconds = Int(durationActual)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        }
        return "\(minutes) min"
    }

    /// Typed session mode. Falls back to .meditation if value is unrecognized.
    var sessionMode: SessionMode {
        SessionMode(rawValue: mode ?? "") ?? .meditation
    }

    /// Completion percentage (0.0 – 1.0)
    var completionRatio: Double {
        guard durationPlanned > 0 else { return 0 }
        return min(Double(durationActual) / Double(durationPlanned), 1.0)
    }

    /// True if the session was cut short (interrupted before planned time)
    var wasShortened: Bool {
        wasInterrupted && durationActual > 0
    }

    /// Friendly relative date, e.g. "Today", "Yesterday", "Mon, 3 Mar"
    var relativeDateString: String {
        guard let date = startTime else { return "Unknown" }
        let cal = Calendar.current
        if cal.isDateInToday(date)     { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }
}

// MARK: - SessionMode Enum
// Defined here so it's available across the whole app.

enum SessionMode: String, CaseIterable, Identifiable {
    case prayer     = "prayer"
    case chanting   = "chanting"
    case meditation = "meditation"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .prayer:     return "Prayer"
        case .chanting:   return "Chanting"
        case .meditation: return "Meditation"
        }
    }

    var systemImage: String {
        switch self {
        case .prayer:     return "hands.and.sparkles.fill"
        case .chanting:   return "waveform"
        case .meditation: return "figure.mind.and.body"
        }
    }

    /// Whether this mode requires the full chant library (premium gate)
    var requiresPremiumForFullLibrary: Bool {
        self == .chanting || self == .prayer
    }

    /// Default session duration in seconds
    var defaultDuration: Int32 {
        switch self {
        case .prayer:     return 600  // 10 min
        case .chanting:   return 300  // 5 min
        case .meditation: return 600  // 10 min
        }
    }
}
