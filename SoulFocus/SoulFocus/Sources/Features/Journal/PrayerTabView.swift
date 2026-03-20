// PrayerTabView.swift

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

struct PrayerTabView: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.sfTheme) private var theme
    @EnvironmentObject private var manager: SessionManager
    @AppStorage("defaultTradition") private var selectedTraditionRaw: String = PrayerTradition.other.rawValue
    private var selectedTradition: PrayerTradition {
        get { PrayerTradition(rawValue: selectedTraditionRaw) ?? .other }
        nonmutating set { selectedTraditionRaw = newValue.rawValue }
    }
    @State private var selectedMinutes: Int = 5
    @State private var showPaywall = false

    private let durations = [1, 3, 5, 10, 15, 30]

    /// Traditions that require a premium subscription.
    private func requiresPremium(_ t: PrayerTradition) -> Bool {
        t != .other
    }

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
                        durationPickerSection
                        traditionPickerSection
                        beginButton
                            .padding(.top, 10)
                        if !container.hasPremiumAccess {
                            trialBanner
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Prayer")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    
            }
            .onAppear {
                // Reset to free tradition if current selection requires premium and user doesn't have access
                if requiresPremium(selectedTradition) && !container.hasPremiumAccess {
                    selectedTraditionRaw = PrayerTradition.other.rawValue
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Speak with God")
                .font(.title2.weight(.bold))
                .foregroundStyle(inkWarm)
            Text("From the heart.")
                .font(.subheadline)
                .foregroundStyle(sienna.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var durationPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DURATION")
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(sienna.opacity(0.55))
            
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
    }

    private var traditionPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CHOOSE YOUR TRADITION")
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(sienna.opacity(0.55))
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach([PrayerTradition.hindu, .christian]) { t in traditionChip(t) }
                }
                HStack(spacing: 8) {
                    ForEach([PrayerTradition.buddhist, .islam]) { t in traditionChip(t) }
                }
                traditionChip(.other)
            }
        }
    }

    @ViewBuilder
    private func traditionChip(_ t: PrayerTradition) -> some View {
        let tint = Color(hex: t.accentHex) ?? saffron
        let selected = selectedTradition == t
        let locked = requiresPremium(t) && !container.hasPremiumAccess
        Button {
            if locked {
                showPaywall = true
            } else {
                withAnimation(.spring(response: 0.25)) { selectedTraditionRaw = t.rawValue }
            }
        } label: {
            HStack(spacing: 6) {
                Text(t.emoji).font(.system(size: 18))
                    .opacity(locked ? 0.5 : 1)
                Text(t.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(locked ? sienna.opacity(0.45) : (selected ? .white : inkWarm))
                Spacer()
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(sienna.opacity(0.4))
                } else if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                locked
                    ? AnyShapeStyle(cardBg.opacity(0.5))
                    : (selected ? AnyShapeStyle(tint) : AnyShapeStyle(cardBg)),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected && !locked ? .clear : cardBord.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: selected && !locked ? tint.opacity(0.28) : .clear, radius: 6, y: 2)
        }
        .hapticOnTap()
    }

    private var trialBanner: some View {
        Button { showPaywall = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles").foregroundStyle(saffron)
                VStack(alignment: .leading, spacing: 2) {
                    Text(container.isInTrial
                         ? "\(container.trialDaysRemaining) days left in your free trial"
                         : "Unlock all traditions")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(inkWarm)
                    Text("Upgrade to access all 5 traditions")
                        .font(.caption2)
                        .foregroundStyle(sienna.opacity(0.7))
                }
                Spacer()
                Text("Upgrade")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(saffron, in: Capsule())
            }
            .padding(14)
            .background(cardBg, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(saffron.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var beginButton: some View {
        Button {
            if requiresPremium(selectedTradition) && !container.hasPremiumAccess {
                showPaywall = true
                return
            }
            let dur = TimeInterval(selectedMinutes * 60)
            manager.begin(
                mode: .prayer,
                duration: dur,
                moodBefore: 3,
                tradition: selectedTradition
            )
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.circle.fill").font(.title3)
                Text("Begin Prayer · \(selectedTradition.displayName)")
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

}
