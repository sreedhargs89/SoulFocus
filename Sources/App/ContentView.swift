// ContentView.swift
// Root tab bar. Each tab is a feature module.
// Placeholder views are replaced phase-by-phase.

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var container: AppContainer
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            // ── Home (Week 2) ──────────────────────────
            HomeTabPlaceholder()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            // ── Progress (Week 4) ──────────────────────
            ProgressTabPlaceholder()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.progress)

            // ── Journal (Week 4) ───────────────────────
            JournalTabPlaceholder()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(AppTab.journal)

            // ── Settings (Week 7) ──────────────────────
            SettingsTabPlaceholder()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(.accentColor)
    }
}

// MARK: - Tab Enum

enum AppTab: Int, Hashable {
    case home, progress, journal, settings
}

// MARK: - Placeholder Views (replaced in later phases)

private struct HomeTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.purple.gradient)
                Text("SoulFocus")
                    .font(.largeTitle.bold())
                Text("Home screen coming in Week 2")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("SoulFocus")
        }
    }
}

private struct ProgressTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Progress",
                systemImage: "chart.bar.fill",
                description: Text("Coming in Week 4")
            )
            .navigationTitle("Progress")
        }
    }
}

private struct JournalTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Journal",
                systemImage: "book.fill",
                description: Text("Coming in Week 4")
            )
            .navigationTitle("Journal")
        }
    }
}

private struct SettingsTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Settings",
                systemImage: "gearshape.fill",
                description: Text("Coming in Week 7")
            )
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppContainer.shared)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
