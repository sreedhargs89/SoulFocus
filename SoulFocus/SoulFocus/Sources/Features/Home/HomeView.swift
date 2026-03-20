// HomeView.swift
// Welcome screen — Sacred Dawn palette. Light, warm, joyful, divine.

import SwiftUI
import CoreData

private let bgTop     = Color(red: 1.00, green: 0.98, blue: 0.93)  // ivory
private let bgMid     = Color(red: 0.99, green: 0.94, blue: 0.84)  // warm amber cream
private let bgBot     = Color(red: 0.97, green: 0.88, blue: 0.74)  // golden champagne
private let cardBg    = Color.white.opacity(0.4)                    // translucent card
private let cardBord  = Color(red: 0.90, green: 0.82, blue: 0.70)
private let saffron   = Color(red: 0.96, green: 0.58, blue: 0.11)
private let saffDark  = Color(red: 0.88, green: 0.44, blue: 0.06)
private let inkWarm   = Color(red: 0.07, green: 0.04, blue: 0.01)
private let btnText   = Color(red: 0.07, green: 0.04, blue: 0.01)
private let sienna    = Color(red: 0.28, green: 0.18, blue: 0.06)   // dark warm brown
private let templeGold = Color(red: 0.92, green: 0.76, blue: 0.28)  // temple gold
// ─────────────────────────────────────────────────────────────────────────────

struct HomeView: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.sfTheme) private var theme

    // We don't start sessions from here anymore, but keeping manager for global states if needed
    @EnvironmentObject private var manager: SessionManager

    @State private var showPaywall = false
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var streaks: FetchedResults<Streak>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MeditationSession.startTime, ascending: false)],
        animation: .default
    ) private var sessions: FetchedResults<MeditationSession>

    private var streak: Streak? { streaks.first }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: bgTop, location: 0),
                        .init(color: bgMid, location: 0.50),
                        .init(color: bgBot, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [saffron.opacity(0.14), .clear],
                    center: .center,
                    startRadius: 10,
                    endRadius: 320
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        if !container.isPremium {
                            trialBanner
                        }
                        greetingSection
                        quoteSection
                        statsGrid
                        if !sessions.isEmpty {
                            recentSessionsSection
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("SoulFocus")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(container)
            }
        }
    }
    
    // MARK: - Trial Banner

    private var trialBanner: some View {
        Button { showPaywall = true } label: {
            HStack(spacing: 12) {
                Image(systemName: container.isInTrial ? "sparkles" : "lock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    if container.isInTrial {
                        let days = container.trialDaysRemaining
                        Text("\(days) day\(days == 1 ? "" : "s") left in your free trial")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    } else {
                        Text("Your free trial has ended")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    Text("Tap to unlock all features")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                Text("Upgrade")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(saffron)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.18), in: Capsule())
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [saffron, saffDark],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: saffron.opacity(0.30), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(timeGreeting)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(inkWarm)
                Text("Your sacred journey continues.")
                    .font(.subheadline)
                    .foregroundStyle(sienna.opacity(0.8))
            }
            Spacer()
            Circle()
                .fill(LinearGradient(colors: [saffron, saffDark], startPoint: .top, endPoint: .bottom))
                .frame(width: 48, height: 48)
                .overlay(Image(systemName: "sparkles").foregroundStyle(.white))
                .shadow(color: saffron.opacity(0.3), radius: 6, y: 3)
        }
        .padding(.horizontal, 4)
    }
    
    private var quoteSection: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(saffron)
                .frame(width: 3)
                .cornerRadius(1.5)

            VStack(alignment: .leading, spacing: 6) {
                Text("\u{201C}You are not a drop in the ocean. You are the entire ocean in a drop.\u{201D}")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(inkWarm.opacity(0.9))
                    .lineSpacing(4)
                Text("— Rumi")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(saffron)
            }
            Spacer()
        }
        .padding(16)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(cardBord.opacity(0.4), lineWidth: 1))
        .shadow(color: saffron.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 16) {
            // Left large box
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(saffron)
                    Spacer()
                }
                Text("\(streak?.currentStreak ?? 0)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(inkWarm)
                Text("Day Streak")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(sienna.opacity(0.7))
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(cardBg, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(cardBord.opacity(0.4), lineWidth: 1))
            .shadow(color: saffron.opacity(0.05), radius: 8, y: 3)

            // Right column of two small boxes
            VStack(spacing: 16) {
                statsSmallBox(
                    value: "\(sessions.count)",
                    label: "Sessions",
                    icon: "checkmark.seal.fill",
                    color: templeGold
                )
                statsSmallBox(
                    value: totalTimeString,
                    label: "Practiced",
                    icon: "clock.fill",
                    color: sienna
                )
            }
        }
        .frame(height: 140)
    }

    private func statsSmallBox(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.caption.weight(.bold)).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.headline.weight(.bold)).foregroundStyle(inkWarm)
                Text(label).font(.caption2).foregroundStyle(sienna.opacity(0.7))
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(cardBord.opacity(0.4), lineWidth: 1))
        .shadow(color: saffron.opacity(0.03), radius: 6, y: 2)
    }
    
    private var totalTimeString: String {
        let secs = sessions.reduce(0.0) { $0 + Double($1.durationActual) }
        let h = Int(secs) / 3600
        let m = (Int(secs) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    // MARK: - Recent Sessions

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Recent Sessions")
            ForEach(sessions.prefix(3)) { session in
                SessionCard(session: session)
            }
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(sienna.opacity(0.70))
    }

    private var timeGreeting: String {
        let h = Calendar.current.component(.hour, from: .now)
        switch h {
        case 5..<12:  return "Good Morning 🌅"
        case 12..<17: return "Good Afternoon ☀️"
        default:      return "Good Evening 🌙"
        }
    }
}

    // StatCell removed as it's replaced by the grid inline methods


private struct SessionCard: View {
    let session: MeditationSession

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(saffron.opacity(0.10))
                    .frame(width: 44, height: 44)
                Image(systemName: session.sessionMode.systemImage)
                    .font(.body)
                    .foregroundStyle(saffron)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(session.sessionMode.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(inkWarm)
                Text(session.relativeDateString)
                    .font(.caption)
                    .foregroundStyle(sienna.opacity(0.75))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(session.formattedDuration)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(inkWarm)
                Text(session.wasInterrupted ? "Incomplete" : "Complete")
                    .font(.caption2)
                    .foregroundStyle(session.wasInterrupted ? .orange : templeGold)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(cardBord.opacity(0.4), lineWidth: 1))
        .shadow(color: saffron.opacity(0.05), radius: 6, y: 2)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AppContainer.shared)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
        .environment(\.sfTheme, CalmTheme())
}
