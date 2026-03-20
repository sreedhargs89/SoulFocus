// PersistenceController.swift
// CoreData stack. The single source of truth for all persistent data.
//
// KEY RULES:
//  • Never edit SoulFocus.xcdatamodeld entities in-place — always create a new version.
//  • Always call save() after mutations.
//  • Streak and UserPreferences are singletons — use fetchOrCreate helpers.

import CoreData
import Foundation

final class PersistenceController {

    // MARK: - Singletons

    /// Production stack backed by an on-disk SQLite store.
    static let shared = PersistenceController()

    /// In-memory stack for SwiftUI Previews and unit tests.
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        controller.seedPreviewData(in: controller.viewContext)
        return controller
    }()

    // MARK: - Properties

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Init

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SoulFocus")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Lightweight migration — safe for schema additions/renames without a mapping model
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                SFLogger.coreData("❌ Store failed to load: \(error.localizedDescription)")
                #if DEBUG
                // Fatal in debug — fix CoreData issues immediately, never ship broken stores
                fatalError("CoreData store load failed: \(error), \(error.userInfo)")
                #endif
            } else {
                SFLogger.coreData("✅ Store loaded: \(storeDescription.url?.lastPathComponent ?? "unknown")")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
            SFLogger.coreData("Context saved ✅")
        } catch {
            SFLogger.coreData("Context save failed ❌: \(error.localizedDescription)")
        }
    }

    // MARK: - Background Work

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }

    // MARK: - Singleton Helpers

    /// Fetches the single UserPreferences row, or creates it on first call.
    @discardableResult
    func fetchOrCreateUserPreferences() -> UserPreferences {
        let request = UserPreferences.fetchRequest()
        request.fetchLimit = 1

        if let existing = (try? viewContext.fetch(request))?.first {
            return existing
        }

        let prefs = UserPreferences(context: viewContext)
        prefs.id = UUID()
        prefs.selectedTheme = "calm"
        prefs.defaultSessionMode = "meditation"
        prefs.defaultDurationSeconds = 600
        prefs.hasCompletedOnboarding = false
        prefs.hasRequestedHealthKit = false
        prefs.distractionBlockingEnabled = false
        prefs.appOpenCount = 0
        save()
        SFLogger.coreData("UserPreferences created (first launch)")
        return prefs
    }

    /// Fetches the single Streak row, or creates it on first call.
    @discardableResult
    func fetchOrCreateStreak() -> Streak {
        let request = Streak.fetchRequest()
        request.fetchLimit = 1

        if let existing = (try? viewContext.fetch(request))?.first {
            return existing
        }

        let streak = Streak(context: viewContext)
        streak.id = UUID()
        streak.currentStreak = 0
        streak.longestStreak = 0
        streak.totalSessionCount = 0
        streak.totalMeditationSeconds = 0
        streak.startDate = Date()
        save()
        SFLogger.coreData("Streak created (first launch)")
        return streak
    }

    // MARK: - Streak Logic

    /// Updates streak counts after a completed session.
    /// Call this immediately after writing the session to CoreData.
    func updateStreak(after session: MeditationSession) {
        guard session.wasCompleted else {
            SFLogger.coreData("Session not completed — streak unchanged")
            return
        }

        let streak = fetchOrCreateStreak()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        defer {
            // Always update totals regardless of streak logic
            streak.totalSessionCount += 1
            streak.totalMeditationSeconds += Int64(session.durationActual)
            streak.lastSessionDate = Date()
            save()
            SFLogger.session(
                "Streak updated — current: \(streak.currentStreak), longest: \(streak.longestStreak)"
            )
        }

        guard let lastDate = streak.lastSessionDate else {
            // Very first session ever
            streak.currentStreak = 1
            streak.longestStreak = 1
            return
        }

        let lastDay = calendar.startOfDay(for: lastDate)

        if lastDay == today {
            // Already practiced today — streak count stays the same, totals still update
            return
        }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        if lastDay == yesterday {
            // Consecutive day ✅
            streak.currentStreak += 1
        } else {
            // Gap in practice — reset
            streak.currentStreak = 1
        }

        streak.longestStreak = max(streak.currentStreak, streak.longestStreak)
    }

    // MARK: - Preview Seeding

    private func seedPreviewData(in context: NSManagedObjectContext) {
        // Streak
        let streak = Streak(context: context)
        streak.id = UUID()
        streak.currentStreak = 7
        streak.longestStreak = 14
        streak.totalSessionCount = 21
        streak.totalMeditationSeconds = 37_800 // ~10.5 hours
        streak.lastSessionDate = Calendar.current.startOfDay(for: Date())
        streak.startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!

        // Sessions (last 5 days)
        let modes: [SessionMode] = [.meditation, .prayer, .chanting, .meditation, .prayer]
        for (index, mode) in modes.enumerated() {
            let session = MeditationSession(context: context)
            session.id = UUID()
            session.mode = mode.rawValue
            session.startTime = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
            session.durationPlanned = 600
            session.durationActual = index == 2 ? 420 : 600 // day 3 was cut short
            session.wasCompleted = index != 2
            session.wasInterrupted = index == 2
            session.distractionBlockingEnabled = index % 2 == 0
            session.moodBefore = 3
            session.moodAfter = Int16(index == 2 ? 3 : 5)
        }

        // User Prefs
        let prefs = UserPreferences(context: context)
        prefs.id = UUID()
        prefs.selectedTheme = "calm"
        prefs.defaultSessionMode = "meditation"
        prefs.defaultDurationSeconds = 600
        prefs.hasCompletedOnboarding = true
        prefs.distractionBlockingEnabled = false
        prefs.appOpenCount = 10

        try? context.save()
        SFLogger.coreData("Preview data seeded ✅")
    }
}
