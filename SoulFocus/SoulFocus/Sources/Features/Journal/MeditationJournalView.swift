// MeditationJournalView.swift
// Dedicated space for Meditation practice, accessible from the Journal tab.
// Clean, focused interface for configuring and starting meditation sessions.

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
private let sienna    = Color(red: 0.28, green: 0.18, blue: 0.06)

struct MeditationJournalView: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.sfTheme) private var theme
    
    // Provided by ContentView
    @EnvironmentObject private var manager: SessionManager
    
    // Meditation Settings
    @State private var selectedMinutes: Int = 10
    @State private var selectedIntention: MeditationIntention = .peace
    @State private var selectedBreathing: BreathingStyle = .box
    @State private var selectedBell: BellInterval = .five

    private let durations = [1, 3, 5, 10, 15, 30]

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
                    VStack(spacing: 24) {
                        headerSection
                        meditationSettingsSection
                        beginButton
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Sanctuary")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Meditation space")
                .font(.title2.weight(.bold))
                .foregroundStyle(inkWarm)
            Text("Silence the mind, find stillness.")
                .font(.subheadline)
                .foregroundStyle(sienna.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var meditationSettingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Duration
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Duration")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(durations, id: \.self) { mins in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedMinutes = mins }
                            } label: {
                                Text("\(mins)m")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(selectedMinutes == mins ? btnText : sienna)
                                    .frame(minWidth: 50)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedMinutes == mins
                                            ? AnyShapeStyle(LinearGradient(colors: [saffron, saffDark],
                                                                           startPoint: .leading,
                                                                           endPoint: .trailing))
                                            : AnyShapeStyle(cardBg),
                                        in: RoundedRectangle(cornerRadius: 14)
                                    )
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedMinutes == mins ? .clear : cardBord.opacity(0.4), lineWidth: 1))
                            }
                            .hapticOnTap()
                        }
                    }
                }
            }
            
            // Intention
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Intention")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MeditationIntention.allCases) { intent in
                            Button {
                                withAnimation { selectedIntention = intent }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(intent.emoji)
                                    Text(intent.rawValue)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(selectedIntention == intent ? btnText : inkWarm)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    selectedIntention == intent
                                        ? AnyShapeStyle(saffron)
                                        : AnyShapeStyle(cardBg),
                                    in: Capsule()
                                )
                                .overlay(Capsule().stroke(selectedIntention == intent ? .clear : cardBord.opacity(0.4), lineWidth: 1))
                            }
                            .hapticOnTap()
                        }
                    }
                }
            }
            
            // Breathing Style
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Breathing Guide")
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(BreathingStyle.allCases) { style in
                        Button {
                            withAnimation { selectedBreathing = style }
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: style.icon)
                                        .font(.title2)
                                        .foregroundStyle(selectedBreathing == style ? btnText : saffron)
                                    Spacer()
                                    if selectedBreathing == style {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.body)
                                            .foregroundStyle(btnText)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(style.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(selectedBreathing == style ? btnText : inkWarm)
                                    Text(style.subtitle)
                                        .font(.caption2)
                                        .foregroundStyle(selectedBreathing == style ? btnText.opacity(0.8) : sienna.opacity(0.7))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                selectedBreathing == style
                                    ? AnyShapeStyle(saffron)
                                    : AnyShapeStyle(cardBg),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedBreathing == style ? .clear : cardBord.opacity(0.4), lineWidth: 1))
                        }
                        .hapticOnTap()
                    }
                }
            }
            
            // Bell Interval
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Interval Bell")
                HStack(spacing: 8) {
                    ForEach(BellInterval.allCases) { interval in
                        Button {
                            withAnimation { selectedBell = interval }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: interval.icon)
                                    .font(.caption)
                                Text(interval.rawValue)
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundStyle(selectedBell == interval ? btnText : sienna)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedBell == interval
                                    ? AnyShapeStyle(saffron)
                                    : AnyShapeStyle(cardBg),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(selectedBell == interval ? .clear : cardBord.opacity(0.4), lineWidth: 1))
                        }
                        .hapticOnTap()
                    }
                }
            }
            
        }
    }

    private var beginButton: some View {
        Button {
            let dur = TimeInterval(selectedMinutes * 60)
            manager.begin(
                mode: .meditation,
                duration: dur,
                moodBefore: 3,
                tradition: .other,  // Not used in meditation
                intention: selectedIntention,
                breathingStyle: selectedBreathing,
                bellInterval: selectedBell
            )
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.circle.fill")
                    .font(.title3)
                Text("Begin Meditation  ·  \(selectedMinutes) min")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(btnText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(colors: [saffron, saffDark],
                               startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .shadow(color: saffron.opacity(0.28), radius: 16, y: 6)
        }
        .hapticOnTap()
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(sienna.opacity(0.55))
    }

}

#Preview {
    MeditationJournalView()
        .environmentObject(AppContainer.shared)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
        .environment(\.sfTheme, CalmTheme())
}
