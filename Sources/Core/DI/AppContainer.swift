// AppContainer.swift
// Central dependency injection container.
// All long-lived services are instantiated here and shared via @EnvironmentObject.
// Services are added phase-by-phase — see roadmap comments below.

import Foundation
import CoreData

@MainActor
final class AppContainer: ObservableObject {

    // MARK: - Singleton
    static let shared = AppContainer()

    // MARK: - Core (Week 1)
    let persistence: PersistenceController

    // MARK: - Phase 3 Services (uncomment when implemented)
    // let audioService: AudioService

    // MARK: - Phase 5 Services
    // let distractionBlockingManager: any DistractionBlockingManaging

    // MARK: - Phase 6 Services
    // let productStore: ProductStore

    // MARK: - Phase 7 Services
    // let notificationScheduler: NotificationScheduler
    // let healthKitService: HealthKitService

    // MARK: - Init
    private init() {
        self.persistence = PersistenceController.shared
        SFLogger.info("✅ AppContainer initialized")
    }

    // MARK: - App Lifecycle

    /// Called once on every app launch from SoulFocusApp.onAppear.
    func onAppLaunch() {
        let prefs = persistence.fetchOrCreateUserPreferences()
        prefs.appOpenCount += 1
        persistence.save()
        SFLogger.info("App launched — open count: \(prefs.appOpenCount)")
    }
}
