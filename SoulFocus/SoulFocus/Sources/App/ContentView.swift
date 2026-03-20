// ContentView.swift
// Root tab bar. Each tab is a feature module.
// Placeholder views are replaced phase-by-phase.

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var container: AppContainer
    @StateObject private var manager = SessionManager(persistence: PersistenceController.shared)
    @State private var selectedTab: AppTab = .home
    @Environment(\.sfTheme) private var theme
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {

            // ── Home ──────────────────────────────────
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            // ── Prayer ──────────────────────
            PrayerTabView()
                .tabItem {
                    Label("Prayer", systemImage: "hands.and.sparkles.fill")
                }
                .tag(AppTab.prayer)

            // ── Meditation ───────────────────────
            MeditationJournalView()
                .tabItem {
                    Label("Meditation", systemImage: "leaf.fill")
                }
                .tag(AppTab.meditation)

            // ── Chanting ──────────────────────
            ChantingTabView()
                .tabItem {
                    Label("Chanting", systemImage: "music.note")
                }
                .tag(AppTab.chanting)
        }
        .tint(.accentColor)
        .environmentObject(manager)
        .fullScreenCover(isPresented: Binding(get: { !hasOnboarded }, set: { _ in })) {
            OnboardingView()
        }
        .fullScreenCover(isPresented: sessionCoverBinding) {
            sessionCoverContent
                .environmentObject(container)
                .environmentObject(manager)
                .environment(\.managedObjectContext, container.persistence.viewContext)
                .environment(\.sfTheme, theme)
        }
    }

    private var sessionCoverBinding: Binding<Bool> {
        Binding(
            get: { manager.phase.isActive || manager.phase.isPaused || manager.phase.completedSession != nil },
            set: { if !$0 { manager.reset() } }
        )
    }

    @ViewBuilder
    private var sessionCoverContent: some View {
        if manager.phase.isActive || manager.phase.isPaused {
            ActiveSessionView(manager: manager)
        } else if let session = manager.phase.completedSession {
            SessionCompleteView(manager: manager, session: session)
        }
    }
}

// MARK: - Tab Enum

enum AppTab: Int, Hashable {
    case home, prayer, meditation, chanting
}

// MARK: - Placeholder Views (replaced in later phases)

// Removed placeholders

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppContainer.shared)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
