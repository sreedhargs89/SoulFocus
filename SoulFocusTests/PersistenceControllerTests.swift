// PersistenceControllerTests.swift
// Unit tests for the CoreData stack.
// All tests run against the in-memory preview store — no disk I/O, no state leakage.

import XCTest
import CoreData
@testable import SoulFocus

final class PersistenceControllerTests: XCTestCase {

    // In-memory controller, reset for each test
    private var controller: PersistenceController!
    private var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        controller = PersistenceController(inMemory: true)
        context    = controller.viewContext
    }

    override func tearDownWithError() throws {
        controller = nil
        context    = nil
    }

    // MARK: - UserPreferences Singleton

    func test_fetchOrCreateUserPreferences_createsOnce() {
        let prefs1 = controller.fetchOrCreateUserPreferences()
        let prefs2 = controller.fetchOrCreateUserPreferences()
        XCTAssertEqual(prefs1.objectID, prefs2.objectID, "Must return same singleton row")
    }

    func test_userPreferences_defaultValues() {
        let prefs = controller.fetchOrCreateUserPreferences()
        XCTAssertEqual(prefs.selectedTheme,        "calm")
        XCTAssertEqual(prefs.defaultSessionMode,   "meditation")
        XCTAssertEqual(prefs.defaultDurationSeconds, 600)
        XCTAssertFalse(prefs.hasCompletedOnboarding)
        XCTAssertFalse(prefs.distractionBlockingEnabled)
        XCTAssertEqual(prefs.appOpenCount, 0)
    }

    // MARK: - Streak Singleton

    func test_fetchOrCreateStreak_createsOnce() {
        let s1 = controller.fetchOrCreateStreak()
        let s2 = controller.fetchOrCreateStreak()
        XCTAssertEqual(s1.objectID, s2.objectID, "Must return same singleton row")
    }

    func test_streak_defaultValues() {
        let streak = controller.fetchOrCreateStreak()
        XCTAssertEqual(streak.currentStreak, 0)
        XCTAssertEqual(streak.longestStreak, 0)
        XCTAssertEqual(streak.totalSessionCount, 0)
        XCTAssertEqual(streak.totalMeditationSeconds, 0)
        XCTAssertNil(streak.lastSessionDate)
    }

    // MARK: - Streak Logic

    func test_updateStreak_firstSessionEver() {
        let session = makeCompletedSession(duration: 600)
        controller.updateStreak(after: session)

        let streak = controller.fetchOrCreateStreak()
        XCTAssertEqual(streak.currentStreak,          1)
        XCTAssertEqual(streak.longestStreak,           1)
        XCTAssertEqual(streak.totalSessionCount,       1)
        XCTAssertEqual(streak.totalMeditationSeconds, 600)
    }

    func test_updateStreak_consecutiveDayIncrementsStreak() {
        // Day 1
        let session1 = makeCompletedSession(duration: 600)
        controller.updateStreak(after: session1)

        // Simulate yesterday's lastSessionDate
        let streak = controller.fetchOrCreateStreak()
        streak.lastSessionDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        // Day 2
        let session2 = makeCompletedSession(duration: 300)
        controller.updateStreak(after: session2)

        XCTAssertEqual(streak.currentStreak,           2)
        XCTAssertEqual(streak.longestStreak,           2)
        XCTAssertEqual(streak.totalSessionCount,       2)
        XCTAssertEqual(streak.totalMeditationSeconds, 900)
    }

    func test_updateStreak_missedDayResetsStreak() {
        let session1 = makeCompletedSession(duration: 600)
        controller.updateStreak(after: session1)

        // Simulate 3 days ago (missed yesterday)
        let streak = controller.fetchOrCreateStreak()
        streak.lastSessionDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!

        let session2 = makeCompletedSession(duration: 600)
        controller.updateStreak(after: session2)

        XCTAssertEqual(streak.currentStreak, 1, "Streak should reset to 1 after a gap")
    }

    func test_updateStreak_sameDayDoesNotIncrement() {
        let session1 = makeCompletedSession(duration: 600)
        controller.updateStreak(after: session1)

        let streak = controller.fetchOrCreateStreak()
        let streakAfterFirst = streak.currentStreak

        // Second session same day
        let session2 = makeCompletedSession(duration: 300)
        controller.updateStreak(after: session2)

        XCTAssertEqual(
            streak.currentStreak, streakAfterFirst,
            "Same-day second session must not increment streak"
        )
        XCTAssertEqual(streak.totalSessionCount, 2, "Total count should still increment")
    }

    func test_updateStreak_incompleteSessionDoesNothing() {
        let session = makeSession(duration: 600, completed: false)
        controller.updateStreak(after: session)

        let streak = controller.fetchOrCreateStreak()
        XCTAssertEqual(streak.currentStreak,    0)
        XCTAssertEqual(streak.totalSessionCount, 0)
    }

    func test_streak_longestStreak_tracksCorrectly() {
        // Build a 3-day streak
        for daysAgo in stride(from: 2, through: 0, by: -1) {
            let session = makeCompletedSession(duration: 600)
            controller.updateStreak(after: session)
            if daysAgo > 0 {
                controller.fetchOrCreateStreak().lastSessionDate =
                    Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            }
        }

        let streak = controller.fetchOrCreateStreak()
        XCTAssertGreaterThanOrEqual(streak.longestStreak, streak.currentStreak)
    }

    // MARK: - MeditationSession

    func test_createSession_persistsCorrectly() throws {
        let session = MeditationSession(context: context)
        session.id              = UUID()
        session.mode            = SessionMode.meditation.rawValue
        session.startTime       = Date()
        session.durationPlanned = 600
        session.durationActual  = 580
        session.wasCompleted    = true
        session.wasInterrupted  = false

        controller.save()

        let fetched = try context.fetch(MeditationSession.fetchRequest())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.durationActual, 580)
        XCTAssertEqual(fetched.first?.sessionMode, .meditation)
    }

    // MARK: - Extensions

    func test_meditationSession_formattedDuration() {
        let session = makeCompletedSession(duration: 3960) // 1 hr 6 min
        XCTAssertEqual(session.formattedDuration, "1 hr 6 min")
    }

    func test_meditationSession_completionRatio() {
        let session = makeSession(duration: 600, completed: false)
        session.durationActual = 300
        XCTAssertEqual(session.completionRatio, 0.5, accuracy: 0.01)
    }

    func test_userPreferences_isInTrial() {
        let prefs = controller.fetchOrCreateUserPreferences()
        prefs.trialStartDate = Date()
        XCTAssertTrue(prefs.isInTrial)

        // Simulate expired trial (4 days ago)
        prefs.trialStartDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        XCTAssertFalse(prefs.isInTrial)
    }

    // MARK: - Helpers

    private func makeCompletedSession(duration: Int32) -> MeditationSession {
        makeSession(duration: duration, completed: true)
    }

    private func makeSession(duration: Int32, completed: Bool) -> MeditationSession {
        let session = MeditationSession(context: context)
        session.id              = UUID()
        session.mode            = SessionMode.meditation.rawValue
        session.startTime       = Date()
        session.durationPlanned = duration
        session.durationActual  = completed ? duration : 0
        session.wasCompleted    = completed
        session.wasInterrupted  = !completed
        return session
    }
}
