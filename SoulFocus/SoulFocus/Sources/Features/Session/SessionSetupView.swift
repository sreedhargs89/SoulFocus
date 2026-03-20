// SessionSetupView.swift
// Sheet for picking mode, duration, and pre-session mood before starting.

import SwiftUI

struct SessionSetupView: View {

    @ObservedObject var manager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.sfTheme) private var theme

    @State private var selectedMode: SessionMode = .meditation
    @State private var selectedMinutes: Int = 10
    @State private var selectedMood: Int = 3
    @State private var selectedTradition: PrayerTradition = .hindu

    private let durationPresets = [1, 5, 10, 15, 20, 30, 45, 60]
    private let moodEmojis = ["😔", "😐", "🙂", "😊", "😄"]

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        modeSection
                        if selectedMode == .prayer {
                            traditionSection
                        } else {
                            durationSection
                        }
                        moodSection
                        beginButton
                    }
                    .padding()
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(theme.accentColor)
                }
            }
        }
    }

    // MARK: - Mode Picker

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Mode")
            HStack(spacing: 12) {
                ForEach(SessionMode.allCases) { mode in
                    ModeCard(mode: mode, isSelected: selectedMode == mode, theme: theme)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            selectedMode = mode
                            selectedMinutes = Int(mode.defaultDuration / 60)
                        }
                }
            }
        }
    }

    // MARK: - Tradition Picker (shown when Prayer is selected)

    private var traditionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Prayer Tradition")
            VStack(spacing: 10) {
                // Top row: Hindu + Christian
                HStack(spacing: 10) {
                    ForEach([PrayerTradition.hindu, .christian]) { tradition in
                        TraditionCard(tradition: tradition,
                                      isSelected: selectedTradition == tradition,
                                      theme: theme)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                selectedTradition = tradition
                            }
                    }
                }
                // Middle row: Buddhist + Islam
                HStack(spacing: 10) {
                    ForEach([PrayerTradition.buddhist, .islam]) { tradition in
                        TraditionCard(tradition: tradition,
                                      isSelected: selectedTradition == tradition,
                                      theme: theme)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                selectedTradition = tradition
                            }
                    }
                }
                // Bottom row: Universal (full width)
                TraditionCard(tradition: .other,
                              isSelected: selectedTradition == .other,
                              theme: theme,
                              fullWidth: true)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        selectedTradition = .other
                    }
            }
        }
    }

    // MARK: - Prayer Note (kept for reference, replaced above)
    private var prayerNoTimerNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "infinity")
                .font(.title3)
                .foregroundStyle(theme.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("No timer")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.primaryText)
                Text("Pray at your own pace and end when ready")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryText)
            }
            Spacer()
        }
        .sfCard()
    }

    // MARK: - Duration Picker

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Duration — \(selectedMinutes) min")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(durationPresets, id: \.self) { minutes in
                        DurationChip(minutes: minutes, isSelected: selectedMinutes == minutes, theme: theme)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                selectedMinutes = minutes
                            }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Mood Before

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("How are you feeling?")
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Text(moodEmojis[index])
                        .font(.system(size: 36))
                        .opacity(selectedMood == index + 1 ? 1.0 : 0.4)
                        .scaleEffect(selectedMood == index + 1 ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMood)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            selectedMood = index + 1
                        }
                }
            }
            .sfCard()
        }
    }

    // MARK: - Begin Button

    private var beginButton: some View {
        Button {
            let duration = selectedMode == .prayer ? TimeInterval(0) : TimeInterval(selectedMinutes * 60)
            manager.begin(
                mode: selectedMode,
                duration: duration,
                moodBefore: Int16(selectedMood),
                tradition: selectedTradition
            )
            dismiss()
        } label: {
            Label("Begin \(selectedMode.displayName)", systemImage: "play.fill")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.buttonBackground, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(theme.primaryText)
        }
        .hapticOnTap(style: .medium)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(theme.primaryText)
    }
}

// MARK: - Mode Card

private struct ModeCard: View {
    let mode: SessionMode
    let isSelected: Bool
    let theme: any AppTheme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: mode.systemImage)
                .font(.system(size: 28))
                .foregroundStyle(isSelected ? theme.accentColor : theme.secondaryText)
            Text(mode.displayName)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? theme.primaryText : theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? theme.accentColor.opacity(0.15) : theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Duration Chip

private struct DurationChip: View {
    let minutes: Int
    let isSelected: Bool
    let theme: any AppTheme

    var body: some View {
        Text("\(minutes) min")
            .font(.subheadline.weight(isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? theme.accentColor : theme.secondaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? theme.accentColor.opacity(0.15) : theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 1.5)
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Tradition Card

private struct TraditionCard: View {
    let tradition: PrayerTradition
    let isSelected: Bool
    let theme: any AppTheme
    var fullWidth: Bool = false

    // Parse the hex accent colour for this tradition
    private var tintColor: Color {
        Color(hex: tradition.accentHex) ?? Color.accentColor
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(tradition.emoji)
                .font(.system(size: 26))

            VStack(alignment: .leading, spacing: 2) {
                Text(tradition.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? tintColor : theme.primaryText)
                Text(traditionSubtitle)
                    .font(.caption2)
                    .foregroundStyle(theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(tintColor)
                    .font(.system(size: 16))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? tintColor.opacity(0.12) : theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? tintColor : Color.clear, lineWidth: 1.5)
                )
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isSelected)
    }

    private var traditionSubtitle: String {
        switch tradition {
        case .hindu:     return "Gayatri · Mrityunjaya · Shanti"
        case .christian: return "Lord's Prayer · Hail Mary · St. Francis"
        case .buddhist:  return "Metta · Om Mani Padme Hum · Heart Sutra"
        case .islam:     return "Al-Fatiha · Ayat Al-Kursi · Tasbeeh"
        case .other:     return "Loving-Kindness · Serenity · Peace"
        }
    }
}

// MARK: - Preview

#Preview {
    SessionSetupView(manager: SessionManager(persistence: PersistenceController.preview))
        .environment(\.sfTheme, CalmTheme())
}
