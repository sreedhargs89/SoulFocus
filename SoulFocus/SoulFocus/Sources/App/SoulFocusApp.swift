// SoulFocusApp.swift
// SoulFocus — Focused Prayer & Meditation Companion
// Entry point. Wires CoreData context and AppContainer into the environment.

import SwiftUI

@main
struct SoulFocusApp: App {

    // UIKit delegate for notifications + lifecycle hooks
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // Single shared container — all services live here
    @StateObject private var container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, container.persistence.viewContext)
                .environmentObject(container)
                .onAppear {
                    container.onAppLaunch()
                    // Begin the 7-day free trial clock on first launch
                    let prefs = container.persistence.fetchOrCreateUserPreferences()
                    prefs.startTrialIfNeeded()
                    container.persistence.save()
                }
        }
    }
}
