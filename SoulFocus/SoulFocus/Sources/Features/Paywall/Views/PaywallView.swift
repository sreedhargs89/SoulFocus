// PaywallView.swift
// Full-screen subscription paywall — Sacred Dawn design system.

import SwiftUI
import StoreKit

// MARK: - Design constants (Sacred Dawn palette)
private let bgTop    = Color(red: 1.00, green: 0.98, blue: 0.93)
private let bgMid    = Color(red: 0.99, green: 0.94, blue: 0.84)
private let bgBot    = Color(red: 0.97, green: 0.88, blue: 0.74)
private let cardBg   = Color.white.opacity(0.45)
private let cardBord = Color(red: 0.90, green: 0.82, blue: 0.70)
private let saffron  = Color(red: 0.96, green: 0.58, blue: 0.11)
private let saffDark = Color(red: 0.88, green: 0.44, blue: 0.06)
private let inkWarm  = Color(red: 0.07, green: 0.04, blue: 0.01)
private let btnText  = Color(red: 0.07, green: 0.04, blue: 0.01)
private let sienna   = Color(red: 0.28, green: 0.18, blue: 0.06)

struct PaywallView: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlanID: String = PremiumStore.annualID
    @State private var isRestoring = false

    private let features: [(icon: String, label: String)] = [
        ("hands.and.sparkles.fill", "All 5 prayer traditions"),
        ("music.note",              "Complete chanting library"),
        ("timer",                   "Sessions up to 60 minutes"),
        ("chart.bar.fill",          "Weekly progress insights"),
        ("bell.badge.fill",         "Custom daily reminders"),
        ("moon.stars.fill",         "Premium themes"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: bgTop, location: 0),
                    .init(color: bgMid, location: 0.5),
                    .init(color: bgBot, location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [saffron.opacity(0.12), .clear],
                center: .top, startRadius: 20, endRadius: 420
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {
                    dismissRow
                    headerSection
                    featureList
                    planSelector
                    ctaButton
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Dismiss

    private var dismissRow: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(sienna.opacity(0.35))
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [saffron, saffDark], startPoint: .top, endPoint: .bottom))
                    .frame(width: 76, height: 76)
                    .shadow(color: saffron.opacity(0.35), radius: 18, y: 8)
                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
            }

            Text("Unlock SoulFocus")
                .font(.title.bold())
                .foregroundStyle(inkWarm)

            Text("Complete your practice.\nEvery tradition. Every session.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(sienna.opacity(0.8))
                .lineSpacing(4)
        }
    }

    // MARK: - Feature List

    private var featureList: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(saffron.opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: feature.icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(saffron)
                    }
                    Text(feature.label)
                        .font(.subheadline)
                        .foregroundStyle(inkWarm)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(saffron)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 16)

                if index < features.count - 1 {
                    Divider()
                        .background(cardBord.opacity(0.3))
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(cardBg, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(cardBord.opacity(0.4), lineWidth: 1))
    }

    // MARK: - Plan Selector

    private var planSelector: some View {
        VStack(spacing: 10) {
            planCard(
                id: PremiumStore.annualID,
                title: "Annual",
                badge: "Best Value",
                price: container.annualProduct?.displayPrice ?? "$29.99",
                detail: "7-day free trial · then $29.99/yr · Save 50%"
            )
            planCard(
                id: PremiumStore.monthlyID,
                title: "Monthly",
                badge: nil,
                price: container.monthlyProduct?.displayPrice ?? "$4.99",
                detail: "Billed monthly, cancel anytime"
            )
            planCard(
                id: PremiumStore.lifetimeID,
                title: "Lifetime",
                badge: "One-time",
                price: container.lifetimeProduct?.displayPrice ?? "$59.99",
                detail: "Pay once, use forever"
            )
        }
    }

    private func planCard(id: String, title: String, badge: String?, price: String, detail: String) -> some View {
        let selected = selectedPlanID == id
        return Button {
            withAnimation(.spring(response: 0.25)) { selectedPlanID = id }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(selected ? saffron : cardBord.opacity(0.6), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle().fill(saffron).frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(inkWarm)
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(saffron, in: Capsule())
                        }
                    }
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(sienna.opacity(0.7))
                }

                Spacer()

                Text(price)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(selected ? saffron : inkWarm)
            }
            .padding(14)
            .background(
                selected ? AnyShapeStyle(saffron.opacity(0.07)) : AnyShapeStyle(cardBg),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? saffron.opacity(0.55) : cardBord.opacity(0.4),
                            lineWidth: selected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button {
            Task { await handleSubscribe() }
        } label: {
            Group {
                if container.isPurchasing {
                    ProgressView().tint(btnText)
                } else {
                    Text(selectedPlanID == PremiumStore.annualID
                         ? "Start 7-Day Free Trial"
                         : "Subscribe Now")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(btnText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(colors: [saffron, saffDark], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .shadow(color: saffron.opacity(0.28), radius: 16, y: 6)
        }
        .disabled(container.isPurchasing)
        .hapticOnTap()
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 12) {
            if let error = container.premiumErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    isRestoring = true
                    await container.restorePurchases()
                    isRestoring = false
                    if container.isPremium { dismiss() }
                }
            } label: {
                Text(isRestoring ? "Restoring…" : "Restore Purchases")
                    .font(.footnote)
                    .foregroundStyle(sienna.opacity(0.7))
                    .underline()
            }
            .disabled(isRestoring)

            Text("Subscriptions renew automatically. Cancel anytime in Settings.")
                .font(.caption2)
                .foregroundStyle(sienna.opacity(0.45))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Purchase Action

    private func handleSubscribe() async {
        let product: Product?
        switch selectedPlanID {
        case PremiumStore.monthlyID:  product = container.monthlyProduct
        case PremiumStore.annualID:   product = container.annualProduct
        case PremiumStore.lifetimeID: product = container.lifetimeProduct
        default: product = nil
        }

        guard let product else {
            await container.premiumStore.loadProducts()
            return
        }

        await container.purchasePremium(product)
        if container.isPremium { dismiss() }
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
        .environmentObject(AppContainer.shared)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
