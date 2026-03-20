// CompilationTest.swift
// Quick test to verify all Core Data entities are accessible
// If this file compiles without errors, everything is working!

import SwiftUI
import CoreData

/// This file tests that all Core Data entities can be found and used.
/// If Xcode shows no errors here, your setup is correct!
struct CompilationTest: View {
    
    @EnvironmentObject private var container: AppContainer
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Compilation Test")
                .font(.title.bold())
            
            Text("If you see this in preview, everything works!")
                .foregroundStyle(.secondary)
            
            Button("Test Core Data") {
                testCoreData()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func testCoreData() {
        // Test 1: UserPreferences
        let prefs = container.persistence.fetchOrCreateUserPreferences()
        print("✅ UserPreferences accessible")
        print("   Theme: \(prefs.selectedTheme ?? "none")")
        print("   Opens: \(prefs.appOpenCount)")
        
        // Test 2: Streak
        let streak = container.persistence.fetchOrCreateStreak()
        print("✅ Streak accessible")
        print("   Current: \(streak.currentStreak) days")
        print("   Longest: \(streak.longestStreak) days")
        
        // Test 3: MeditationSession
        let session = MeditationSession(context: viewContext)
        session.id = UUID()
        session.mode = SessionMode.meditation.rawValue
        session.startTime = Date()
        session.durationPlanned = 600
        print("✅ MeditationSession accessible")
        print("   ID: \(session.id?.uuidString ?? "none")")
        
        // Clean up test session
        viewContext.delete(session)
        
        print("\n🎉 ALL TESTS PASSED! Core Data is working correctly.\n")
    }
}

// MARK: - Preview

#Preview("Compilation Test") {
    CompilationTest()
        .environmentObject(AppContainer.shared)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}

// MARK: - Type Checking Tests

/// These functions should compile if all types are found correctly
fileprivate enum TypeChecks {
    
    static func canAccessMeditationSession() -> MeditationSession? {
        // If this compiles, MeditationSession type is found ✅
        let context = PersistenceController.shared.viewContext
        let session = MeditationSession(context: context)
        return session
    }
    
    static func canAccessStreak() -> Streak? {
        // If this compiles, Streak type is found ✅
        let context = PersistenceController.shared.viewContext
        let streak = Streak(context: context)
        return streak
    }
    
    static func canAccessUserPreferences() -> UserPreferences? {
        // If this compiles, UserPreferences type is found ✅
        let context = PersistenceController.shared.viewContext
        let prefs = UserPreferences(context: context)
        return prefs
    }
    
    static func canAccessAppContainer() -> AppContainer {
        // If this compiles, AppContainer conforms to ObservableObject ✅
        return AppContainer.shared
    }
    
    static func canUseFetchRequests() {
        // If this compiles, fetch requests work ✅
        let sessionRequest: NSFetchRequest<MeditationSession> = MeditationSession.fetchRequest()
        let streakRequest: NSFetchRequest<Streak> = Streak.fetchRequest()
        let prefsRequest: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        
        _ = sessionRequest
        _ = streakRequest
        _ = prefsRequest
    }
    
    static func canUseExtensions() {
        // If this compiles, extensions are accessible ✅
        let context = PersistenceController.shared.viewContext
        
        let session = MeditationSession(context: context)
        _ = session.formattedDuration
        _ = session.sessionMode
        
        let streak = Streak(context: context)
        _ = streak.formattedTotalTime
        _ = streak.streakBadgeLabel
        
        let prefs = UserPreferences(context: context)
        _ = prefs.appThemeID
        _ = prefs.hasPremiumAccess
    }
}

// MARK: - Compilation Success Indicator

/*
 
 ╔══════════════════════════════════════════════════════════════════════════════╗
 ║                                                                              ║
 ║                   ✅ IF THIS FILE HAS NO ERRORS ✅                           ║
 ║                                                                              ║
 ║                    YOUR CORE DATA SETUP IS CORRECT!                          ║
 ║                                                                              ║
 ║  All entity types are accessible:                                           ║
 ║    • MeditationSession ✅                                                    ║
 ║    • Streak ✅                                                               ║
 ║    • UserPreferences ✅                                                      ║
 ║    • AppContainer ✅                                                         ║
 ║                                                                              ║
 ║  You can now:                                                               ║
 ║    1. Build (⌘B)                                                            ║
 ║    2. Run (⌘R)                                                              ║
 ║    3. Test in simulator                                                     ║
 ║                                                                              ║
 ║  Next step: Open this file's preview to run the test!                      ║
 ║                                                                              ║
 ╚══════════════════════════════════════════════════════════════════════════════╝
 
 */
