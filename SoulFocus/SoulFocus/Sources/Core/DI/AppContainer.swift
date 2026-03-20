// AppContainer.swift
// Central dependency injection container.
// All long-lived services are instantiated here and shared via @EnvironmentObject.

import Foundation
import CoreData
import SwiftUI
import Combine
import StoreKit

final class AppContainer: ObservableObject {

    // MARK: - Singleton
    @MainActor
    static let shared = AppContainer()

    // MARK: - Core
    let persistence: PersistenceController

    // MARK: - Monetization (internal — views access via convenience properties below)
    let premiumStore: PremiumStore

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init
    private init() {
        let persistence = PersistenceController.shared
        self.persistence = persistence
        self.premiumStore = PremiumStore(persistence: persistence)
        SFLogger.info("✅ AppContainer initialized")

        // Forward PremiumStore state changes → views re-render via AppContainer
        premiumStore.$isPremium
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        premiumStore.$isPurchasing
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        premiumStore.$products
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        premiumStore.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - App Lifecycle

    /// Called once on every app launch from SoulFocusApp.onAppear.
    func onAppLaunch() {
        let prefs = persistence.fetchOrCreateUserPreferences()
        prefs.appOpenCount += 1
        persistence.save()
        SFLogger.info("App launched — open count: \(prefs.appOpenCount)")
    }

    // MARK: - Premium State (read-only, derived from PremiumStore)

    var hasPremiumAccess: Bool    { premiumStore.hasPremiumAccess }
    var isPremium: Bool           { premiumStore.isPremium }
    var isPurchasing: Bool        { premiumStore.isPurchasing }
    var isInTrial: Bool           { premiumStore.isInTrial }
    var trialDaysRemaining: Int   { premiumStore.trialDaysRemaining }
    var premiumErrorMessage: String? { premiumStore.errorMessage }

    // StoreKit products
    var premiumProducts: [Product] { premiumStore.products }
    var monthlyProduct:  Product?  { premiumStore.monthlyProduct }
    var annualProduct:   Product?  { premiumStore.annualProduct }
    var lifetimeProduct: Product?  { premiumStore.lifetimeProduct }

    // MARK: - Premium Actions (delegates to PremiumStore)

    func purchasePremium(_ product: Product) async {
        await premiumStore.purchase(product)
    }

    func restorePurchases() async {
        await premiumStore.restore()
    }
}
