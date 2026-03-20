// TrialOnboardingView.swift
// Step 2 of onboarding — presents the 7-day free trial offer clearly.
// Shown after tradition picker, before entering the main app.

import SwiftUI

struct TrialOnboardingView: View {

    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @EnvironmentObject private var container: AppContainer

    // Dark Sacred Dawn palette (matches OnboardingView)
    private let bg       = Color(red: 0.07, green: 0.05, blue: 0.12)
    private let card     = Color(red: 0.13, green: 0.10, blue: 0.20)
    private let cardBord = Color.white.opacity(0.10)
    private let saffron  = Color(red: 0.96, green: 0.58, blue: 0.11)
    private let saffDark = Color(red: 0.88, green: 0.44, blue: 0.06)

    private let perks: [(icon: String, label: String)] = [
        ("hands.and.sparkles.fill", "All 5 prayer traditions"),
        ("music.note",              "Complete chanting library"),
        ("timer",                   "Sessions up to 60 minutes"),
        ("chart.bar.fill",          "Weekly progress insights"),
        ("bell.badge.fill",         "Custom daily reminders"),
    ]

    @State private var animateIn   = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            RadialGradient(
                colors: [saffron.opacity(0.18), .clear],
                center: .top, startRadius: 0, endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Header ────────────────────────────────────────────────────
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [saffron, saffDark],
                                startPoint: .top, endPoint: .bottom
                            ))
                            .frame(width: 80, height: 80)
                            .shadow(color: saffron.opacity(0.40), radius: 20, y: 8)
                        Image(systemName: "sparkles")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1), value: animateIn)

                    Text("Try SoulFocus Free")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.25), value: animateIn)

                    Text("7 days of full access.\nNo charge today.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.60))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 12)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: animateIn)
                }

                Spacer().frame(height: 32)

                // ── Perks list ────────────────────────────────────────────────
                VStack(spacing: 0) {
                    ForEach(Array(perks.enumerated()), id: \.offset) { idx, perk in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(saffron.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: perk.icon)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(saffron)
                            }
                            Text(perk.label)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(saffron)
                        }
                        .padding(.vertical, 13)
                        .padding(.horizontal, 16)

                        if idx < perks.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.08))
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(card, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(cardBord, lineWidth: 1))
                .padding(.horizontal, 24)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 24)
                .animation(.easeOut(duration: 0.55).delay(0.45), value: animateIn)

                Spacer()

                // ── CTAs ──────────────────────────────────────────────────────
                VStack(spacing: 14) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hasOnboarded = true
                        }
                    } label: {
                        Text("Start 7-Day Free Trial")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color(red: 0.07, green: 0.04, blue: 0.01))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(
                                    colors: [saffron, saffDark],
                                    startPoint: .leading, endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                            .shadow(color: saffron.opacity(0.40), radius: 14, y: 6)
                    }
                    .hapticOnTap(style: .medium)

                    Button {
                        showPaywall = true
                    } label: {
                        Text("See pricing plans")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.50))
                            .underline()
                    }

                    Text("No payment required today. Cancel anytime.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.30))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
                .opacity(animateIn ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: animateIn)
            }
        }
        .onAppear { animateIn = true }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(container)
        }
    }
}

#Preview {
    TrialOnboardingView()
        .environmentObject(AppContainer.shared)
}
