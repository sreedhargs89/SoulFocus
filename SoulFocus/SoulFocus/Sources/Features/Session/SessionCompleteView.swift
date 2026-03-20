// SessionCompleteView.swift
// Post-session screen: completion status, duration, mood-after rating, streak card.

import SwiftUI
import CoreData

struct SessionCompleteView: View {

    @ObservedObject var manager: SessionManager
    let session: MeditationSession

    @EnvironmentObject private var container: AppContainer
    @Environment(\.sfTheme) private var theme

    @FetchRequest(sortDescriptors: [], animation: .default)
    private var streaks: FetchedResults<Streak>

    @State private var selectedMoodAfter: Int = 3
    @State private var showPaywall = false

    private let moodEmojis = ["😔", "😐", "🙂", "😊", "😄"]
    private var streak: Streak? { streaks.first }

    var body: some View {
        ZStack {
            theme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    completionHeader
                    durationCard
                    moodSection
                    if let streak { streakCard(streak) }
                    if !container.hasPremiumAccess {
                        trialUpsellCard
                    }
                    saveButton
                }
                .padding()
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                
        }
    }

    // MARK: - Header

    private var completionHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: session.wasCompleted ? "checkmark.circle.fill" : "clock.badge.xmark")
                .font(.system(size: 64))
                .foregroundStyle(session.wasCompleted ? theme.accentColor : .orange)
                .padding(.top, 24)

            Text(session.wasCompleted ? "Session Complete" : "Session Ended Early")
                .font(.title2.bold())
                .foregroundStyle(theme.primaryText)

            Label(manager.selectedMode.displayName, systemImage: manager.selectedMode.systemImage)
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
        }
    }

    // MARK: - Duration Summary

    private var durationCard: some View {
        HStack(spacing: 0) {
            statItem(label: "Duration", value: session.formattedDuration)

            Rectangle()
                .fill(Color(red: 0.90, green: 0.82, blue: 0.70).opacity(0.5))
                .frame(width: 0.5, height: 40)

            statItem(label: "Planned", value: TimeInterval(session.durationPlanned).durationString)
        }
        .sfCard()
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(theme.primaryText)
            Text(label)
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Mood After

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How do you feel now?")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Text(moodEmojis[index])
                        .font(.system(size: 36))
                        .opacity(selectedMoodAfter == index + 1 ? 1.0 : 0.4)
                        .scaleEffect(selectedMoodAfter == index + 1 ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMoodAfter)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            selectedMoodAfter = index + 1
                        }
                }
            }
            .sfCard()
        }
    }

    // MARK: - Streak

    private func streakCard(_ streak: Streak) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Streak")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(streak.currentStreak)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(theme.accentColor)
                    Text("day streak")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                }

                Spacer()

                Text(streak.streakBadgeLabel)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 180)
            }
            .sfCard()
        }
    }

    // MARK: - Trial Upsell

    private var trialUpsellCard: some View {
        let saffron = Color(red: 0.96, green: 0.58, blue: 0.11)
        let saffDark = Color(red: 0.88, green: 0.44, blue: 0.06)
        let inkWarm = Color(red: 0.07, green: 0.04, blue: 0.01)
        let sienna = Color(red: 0.28, green: 0.18, blue: 0.06)

        return Button { showPaywall = true } label: {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(saffron)
                    Text(container.isInTrial
                         ? "\(container.trialDaysRemaining) days left in your free trial"
                         : "Upgrade to SoulFocus Premium")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(inkWarm)
                    Spacer()
                }
                Text("Unlock all traditions, extended sessions, and progress insights.")
                    .font(.caption)
                    .foregroundStyle(sienna.opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("See Plans")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [saffron, saffDark], startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .padding(16)
            .background(saffron.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(saffron.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            session.moodAfter = Int16(selectedMoodAfter)
            container.persistence.save()
            manager.reset()
        } label: {
            Text("Done")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.buttonBackground, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(theme.primaryText)
        }
        .hapticOnTap(style: .medium)
    }
}

// MARK: - Preview

#Preview {
    let persistence = PersistenceController.preview
    let session = MeditationSession(context: persistence.viewContext)
    session.id = UUID()
    session.mode = SessionMode.meditation.rawValue
    session.startTime = Date()
    session.durationPlanned = 600
    session.durationActual = 600
    session.wasCompleted = true
    session.wasInterrupted = false
    session.moodBefore = 3

    return SessionCompleteView(
        manager: SessionManager(persistence: persistence),
        session: session
    )
    .environmentObject(AppContainer.shared)
    .environment(\.managedObjectContext, persistence.viewContext)
    .environment(\.sfTheme, CalmTheme())
}
