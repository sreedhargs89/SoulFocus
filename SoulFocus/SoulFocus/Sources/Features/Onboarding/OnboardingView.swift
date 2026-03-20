// OnboardingView.swift
// Shown once at first launch — lets the user pick their spiritual tradition.
// Stored via @AppStorage so every screen starts pre-selected.

import SwiftUI

struct OnboardingView: View {

    @AppStorage("defaultTradition") private var storedTradition: String = PrayerTradition.hindu.rawValue
    @AppStorage("hasOnboarded")    private var hasOnboarded: Bool       = false

    @EnvironmentObject private var container: AppContainer

    @State private var selected: PrayerTradition = .hindu
    @State private var animateIn = false
    @State private var showTrialScreen = false

    // Palette
    private let bg       = Color(red: 0.07, green: 0.05, blue: 0.12)
    private let card     = Color(red: 0.13, green: 0.10, blue: 0.20)
    private let cardBord = Color.white.opacity(0.10)
    private let saffron  = Color(red: 0.96, green: 0.58, blue: 0.11)
    private let saffDark = Color(red: 0.88, green: 0.44, blue: 0.06)

    var body: some View {
        ZStack {
            // Deep spiritual background
            bg.ignoresSafeArea()
            RadialGradient(
                colors: [saffron.opacity(0.18), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Header ───────────────────────────────────────────────────
                VStack(spacing: 12) {
                    Text("🕊️")
                        .font(.system(size: 56))
                        .scaleEffect(animateIn ? 1 : 0.5)
                        .opacity(animateIn ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1), value: animateIn)

                    Text("Welcome to SoulFocus")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.25), value: animateIn)

                    Text("Choose your spiritual tradition.\nThis will be your default — you can always change it.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.60))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 12)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: animateIn)
                }

                Spacer().frame(height: 36)

                // ── Tradition grid ───────────────────────────────────────────
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        traditionCard(.hindu)
                        traditionCard(.christian)
                    }
                    HStack(spacing: 10) {
                        traditionCard(.buddhist)
                        traditionCard(.islam)
                    }
                    traditionCard(.other)
                }
                .padding(.horizontal, 24)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 24)
                .animation(.easeOut(duration: 0.55).delay(0.45), value: animateIn)

                Spacer()

                // ── Continue button ──────────────────────────────────────────
                Button {
                    storedTradition = selected.rawValue
                    showTrialScreen = true
                } label: {
                    Text("Continue with \(selected.displayName)")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(red: 0.07, green: 0.04, blue: 0.01))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(colors: [saffron, saffDark],
                                           startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .shadow(color: saffron.opacity(0.40), radius: 14, y: 6)
                }
                .hapticOnTap(style: .medium)
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
                .opacity(animateIn ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: animateIn)
            }
        }
        .onAppear {
            // Seed selection from any previously stored value (re-launch guard)
            selected = PrayerTradition(rawValue: storedTradition) ?? .hindu
            animateIn = true
        }
        .fullScreenCover(isPresented: $showTrialScreen) {
            TrialOnboardingView()
                .environmentObject(container)
        }
    }

    // MARK: - Tradition card

    @ViewBuilder
    private func traditionCard(_ t: PrayerTradition) -> some View {
        let tint     = Color(hex: t.accentHex) ?? saffron
        let isActive = selected == t

        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                selected = t
            }
        } label: {
            HStack(spacing: 10) {
                Text(t.emoji)
                    .font(.system(size: 22))
                Text(t.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isActive ? .white : .white.opacity(0.75))
                Spacer()
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(tint)
                        .font(.body)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                isActive
                    ? AnyShapeStyle(tint.opacity(0.22))
                    : AnyShapeStyle(card),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isActive ? tint.opacity(0.70) : cardBord, lineWidth: 1.5)
            )
            .shadow(color: isActive ? tint.opacity(0.25) : .clear, radius: 8, y: 3)
        }
        .hapticOnTap()
    }
}

#Preview {
    OnboardingView()
}
