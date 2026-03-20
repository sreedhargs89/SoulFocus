// SessionManager.swift
// Session lifecycle state machine with a 1-second countdown Timer.

import Foundation
import CoreData
import Combine

// MARK: - Prayer Tradition

enum PrayerTradition: String, CaseIterable, Identifiable {
    case hindu      = "hindu"
    case christian  = "christian"
    case buddhist   = "buddhist"
    case islam      = "islam"
    case other      = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hindu:     return "Hindu"
        case .christian: return "Christian"
        case .buddhist:  return "Buddhist"
        case .islam:     return "Islam"
        case .other:     return "Universal"
        }
    }

    var emoji: String {
        switch self {
        case .hindu:     return "🕉️"
        case .christian: return "✝️"
        case .buddhist:  return "☸️"
        case .islam:     return "☪️"
        case .other:     return "🌍"
        }
    }

    var systemImage: String {
        switch self {
        case .hindu:     return "sparkles"
        case .christian: return "cross.fill"
        case .buddhist:  return "circle.hexagongrid.fill"
        case .islam:     return "moon.stars.fill"
        case .other:     return "globe.americas.fill"
        }
    }

    var accentHex: String {
        switch self {
        case .hindu:     return "#E8940F"   // saffron
        case .christian: return "#3B6FD4"   // royal blue
        case .buddhist:  return "#C4763B"   // gold-brown
        case .islam:     return "#2E7D52"   // islamic green
        case .other:     return "#7B5EA7"   // violet
        }
    }
}

// MARK: - Session Phase

enum SessionPhase {
    case idle
    case active
    case paused
    case complete(MeditationSession)

    var isActive: Bool {
        if case .active = self { return true }
        return false
    }

    var isPaused: Bool {
        if case .paused = self { return true }
        return false
    }

    var completedSession: MeditationSession? {
        if case .complete(let session) = self { return session }
        return nil
    }
}

extension SessionPhase: Equatable {
    static func == (lhs: SessionPhase, rhs: SessionPhase) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):     return true
        case (.active, .active): return true
        case (.paused, .paused): return true
        case (.complete(let a), .complete(let b)): return a === b
        default: return false
        }
    }
}

// MARK: - Session Manager

@MainActor
final class SessionManager: ObservableObject {

    // MARK: Published State

    @Published var phase: SessionPhase = .idle
    @Published var timeRemaining: TimeInterval = 0
    @Published var progress: Double = 0  // 0.0 → 1.0

    // MARK: Read-Only Config

    private(set) var selectedMode: SessionMode = .meditation
    private(set) var plannedDuration: TimeInterval = 600
    private(set) var selectedTradition: PrayerTradition = .hindu
    private(set) var meditationIntention: MeditationIntention = .peace
    private(set) var breathingStyle: BreathingStyle = .box
    private(set) var bellInterval: BellInterval = .five

    // MARK: Private

    private var timer: Timer?
    private var activeSession: MeditationSession?
    private var sessionStartTime: Date?
    private let persistence: PersistenceController

    // MARK: Init

    init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    // MARK: Actions

    func begin(mode: SessionMode, duration: TimeInterval, moodBefore: Int16,
                tradition: PrayerTradition = .hindu,
                intention: MeditationIntention = .peace,
                breathingStyle: BreathingStyle = .box,
                bellInterval: BellInterval = .five) {
        timer?.invalidate()
        timer = nil

        let session = MeditationSession(context: persistence.viewContext)
        session.id = UUID()
        session.mode = mode.rawValue
        session.startTime = Date()
        session.durationPlanned = Int32(duration)
        session.moodBefore = moodBefore
        session.wasCompleted = false
        session.wasInterrupted = false
        session.distractionBlockingEnabled = false

        activeSession = session
        selectedMode = mode
        selectedTradition = tradition
        meditationIntention = intention
        self.breathingStyle = breathingStyle
        self.bellInterval = bellInterval
        plannedDuration = duration
        timeRemaining = duration
        progress = 0
        sessionStartTime = Date()

        scheduleTimer()
        phase = .active
    }

    func pause() {
        guard case .active = phase else { return }
        timer?.invalidate()
        timer = nil
        phase = .paused
    }

    func resume() {
        guard case .paused = phase else { return }
        scheduleTimer()
        phase = .active
    }

    func end(completed: Bool) {
        timer?.invalidate()
        timer = nil

        guard let session = activeSession else { return }
        activeSession = nil

        let elapsed = sessionStartTime.map { Date().timeIntervalSince($0) } ?? max(plannedDuration - timeRemaining, 1)
        session.durationActual = Int32(max(elapsed, 1))
        session.wasCompleted = completed
        session.wasInterrupted = !completed
        sessionStartTime = nil

        persistence.save()
        if completed { persistence.updateStreak(after: session) }

        phase = .complete(session)
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        activeSession = nil
        sessionStartTime = nil
        timeRemaining = 0
        progress = 0
        phase = .idle
    }

    // MARK: Private

    private func scheduleTimer() {
        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        if plannedDuration == 0 {
            timeRemaining += 1
            return
        }

        guard timeRemaining > 0 else {
            end(completed: true)
            return
        }
        timeRemaining -= 1
        progress = 1.0 - (timeRemaining / plannedDuration)
    }
}
