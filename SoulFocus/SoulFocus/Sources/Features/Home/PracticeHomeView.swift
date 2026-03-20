// PracticeHomeView.swift
// Sacred Dawn — light, warm, everything visible, zero extra taps.

import SwiftUI
import CoreData

// ── Sacred Dawn palette ──────────────────────────────────────────────────────
private let bg        = Color(red: 0.99, green: 0.97, blue: 0.92)   // warm ivory
private let cardBg    = Color(red: 1.00, green: 0.99, blue: 0.96)   // warm white card
private let cardBord  = Color(red: 0.90, green: 0.82, blue: 0.70)   // warm taupe border
private let saffron   = Color(red: 0.96, green: 0.58, blue: 0.11)   // saffron fire
private let saffDark  = Color(red: 0.88, green: 0.44, blue: 0.06)   // deep saffron
private let inkWarm   = Color(red: 0.07, green: 0.04, blue: 0.01)   // near-black warm
private let btnText   = Color(red: 0.07, green: 0.04, blue: 0.01)   // button text
private let sienna    = Color(red: 0.28, green: 0.18, blue: 0.06)   // dark warm brown
private let templeGold = Color(red: 0.92, green: 0.76, blue: 0.28)  // temple gold
// ─────────────────────────────────────────────────────────────────────────────

private struct PracticeModeInfo {
    let mode: SessionMode
    let description: String
    let icon: String
}

private let practiceOptions: [PracticeModeInfo] = [
    .init(mode: .prayer,     description: "Speak with God\nfrom the heart",       icon: "hands.and.sparkles.fill"),
    .init(mode: .chanting,   description: "Chant sacred\nnames & mantras",        icon: "music.note"),
]

struct PracticeHomeView: View {

    @ObservedObject var manager: SessionManager
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(sortDescriptors: [], animation: .default)
    private var streaks: FetchedResults<Streak>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MeditationSession.startTime, ascending: false)],
        animation: .default
    ) private var sessions: FetchedResults<MeditationSession>

    @State private var selectedMode: SessionMode = .prayer
    @AppStorage("defaultTradition") private var selectedTraditionRaw: String = PrayerTradition.hindu.rawValue
    private var selectedTradition: PrayerTradition {
        get { PrayerTradition(rawValue: selectedTraditionRaw) ?? .hindu }
        nonmutating set { selectedTraditionRaw = newValue.rawValue }
    }

    private var streak: Streak? { streaks.first }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    greetingSection
                    modePickerSection
                    traditionPickerSection
                    beginButton
                    statsRow
                    if !sessions.isEmpty {
                        recentSessionsSection
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 48)
            }
        }
        .navigationTitle("Your Practice")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(bg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timeGreeting)
                .font(.title.weight(.bold))
                .foregroundStyle(inkWarm)
            Text("What will you practice today?")
                .font(.subheadline)
                .foregroundStyle(sienna)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: - Mode Picker

    private var modePickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Choose Your Practice")
            HStack(spacing: 10) {
                ForEach(practiceOptions, id: \.mode) { info in
                    PracticeModeCard(info: info, isSelected: selectedMode == info.mode) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedMode = info.mode
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tradition Picker (shows instead of duration when Prayer is selected)

    private var traditionPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Choose Your Tradition")
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach([PrayerTradition.hindu, .christian]) { t in
                        traditionChip(t)
                    }
                }
                HStack(spacing: 8) {
                    ForEach([PrayerTradition.buddhist, .islam]) { t in
                        traditionChip(t)
                    }
                }
                traditionChip(.other)
            }
        }
    }

    @ViewBuilder
    private func traditionChip(_ t: PrayerTradition) -> some View {
        let tint = Color(hex: t.accentHex) ?? saffron
        let selected = selectedTradition == t
        Button {
            withAnimation(.spring(response: 0.25)) { selectedTraditionRaw = t.rawValue }
        } label: {
            HStack(spacing: 6) {
                Text(t.emoji).font(.system(size: 18))
                Text(t.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selected ? .white : inkWarm)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                selected
                    ? AnyShapeStyle(tint)
                    : AnyShapeStyle(cardBg),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? .clear : cardBord.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: selected ? tint.opacity(0.28) : .clear, radius: 6, y: 2)
        }
        .hapticOnTap()
    }

    // MARK: - Begin button

    private var beginButton: some View {
        Button {
            manager.begin(
                mode: selectedMode,
                duration: 0,
                moodBefore: 3,
                tradition: selectedTradition
            )
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.circle.fill")
                    .font(.title3)
                Text(beginLabel)
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(btnText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(colors: [saffron, saffDark],
                               startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: saffron.opacity(0.28), radius: 12, y: 5)
        }
        .hapticOnTap()
    }

    // MARK: - Stats row

    private var statsRow: some View {
        HStack(spacing: 0) {
            StatCell(value: "\(streak?.currentStreak ?? 0)",
                     label: "Day Streak",
                     icon: "flame.fill",
                     iconColor: saffron)
            Divider()
                .frame(height: 36)
                .overlay(cardBord.opacity(0.5))
            StatCell(value: "\(sessions.count)",
                     label: "Sessions",
                     icon: "checkmark.seal.fill",
                     iconColor: templeGold)
            Divider()
                .frame(height: 36)
                .overlay(cardBord.opacity(0.5))
            StatCell(value: totalTimeString,
                     label: "Practiced",
                     icon: "clock.fill",
                     iconColor: sienna)
        }
        .padding(.vertical, 16)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(cardBord.opacity(0.50), lineWidth: 1))
        .shadow(color: saffron.opacity(0.07), radius: 8, y: 3)
    }

    private var beginLabel: String {
        switch selectedMode {
        case .prayer:     return "Begin Prayer · \(selectedTradition.displayName)"
        case .chanting:   return "Begin Chanting · \(selectedTradition.displayName)"
        case .meditation: return "Begin Session" // Should be unused now
        }
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
            ForEach(sessions.prefix(2)) { session in
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

// MARK: - Practice Mode Card

private struct PracticeModeCard: View {
    let info: PracticeModeInfo
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? btnText.opacity(0.12) : saffron.opacity(0.10))
                        .frame(width: 52, height: 52)
                    Image(systemName: info.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? btnText : saffron)
                }

                Text(info.mode.displayName)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(isSelected ? btnText : inkWarm)

                Text(info.description)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? btnText.opacity(0.65) : sienna)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 6)
            .background(
                isSelected
                    ? AnyShapeStyle(LinearGradient(colors: [saffron, saffDark],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing))
                    : AnyShapeStyle(cardBg),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .clear : cardBord.opacity(0.55), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? saffron.opacity(0.22) : saffron.opacity(0.06),
                radius: isSelected ? 10 : 4,
                y: 3
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
        }
        .hapticOnTap()
    }
}

// MARK: - Stat Cell

private struct StatCell: View {
    let value: String
    let label: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(inkWarm)
            Text(label)
                .font(.caption2)
                .foregroundStyle(sienna.opacity(0.70))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Card

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
        .background(cardBg, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(cardBord.opacity(0.45), lineWidth: 1))
        .shadow(color: saffron.opacity(0.05), radius: 4, y: 2)
    }
}
