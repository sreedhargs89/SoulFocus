// PremiumStore.swift
// StoreKit 2 product fetching, purchase handling, and entitlement verification.
// State changes are published to AppContainer which re-fires objectWillChange for views.

import StoreKit
import Foundation
import Combine

final class PremiumStore {

    // MARK: - Product IDs (must match App Store Connect exactly)
    static let monthlyID  = "soulfocus.premium.monthly"
    static let annualID   = "soulfocus.premium.annual"
    static let lifetimeID = "soulfocus.premium.lifetime"
    static let allIDs: Set<String> = [monthlyID, annualID, lifetimeID]

    // MARK: - Published State (subscribed by AppContainer)
    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium: Bool = false
    @Published private(set) var isPurchasing: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private
    private let persistence: PersistenceController
    private var listenerTask: Task<Void, Never>?

    // MARK: - Init
    init(persistence: PersistenceController) {
        self.persistence = persistence
        listenerTask = startTransactionListener()
        Task { @MainActor in
            await self.loadProducts()
            await self.verifyEntitlements()
        }
    }

    deinit { listenerTask?.cancel() }

    // MARK: - Convenience Accessors

    var monthlyProduct:  Product? { products.first { $0.id == Self.monthlyID } }
    var annualProduct:   Product? { products.first { $0.id == Self.annualID } }
    var lifetimeProduct: Product? { products.first { $0.id == Self.lifetimeID } }

    /// True if the user has an active subscription OR is within their 7-day free trial.
    var hasPremiumAccess: Bool {
        isPremium || persistence.fetchOrCreateUserPreferences().isInTrial
    }

    var trialDaysRemaining: Int {
        persistence.fetchOrCreateUserPreferences().trialDaysRemaining
    }

    var isInTrial: Bool {
        persistence.fetchOrCreateUserPreferences().isInTrial
    }

    // MARK: - Load Products

    @MainActor
    func loadProducts() async {
        do {
            let fetched = try await Product.products(for: Self.allIDs)
            let order = [Self.monthlyID, Self.annualID, Self.lifetimeID]
            products = fetched.sorted {
                (order.firstIndex(of: $0.id) ?? 99) < (order.firstIndex(of: $1.id) ?? 99)
            }
        } catch {
            // Products unavailable in simulator — UI falls back to hardcoded display prices
        }
    }

    // MARK: - Purchase

    @MainActor
    func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let tx = try Self.verified(verification)
                setIsPremium(productID: tx.productID)
                await tx.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
    }

    // MARK: - Restore

    @MainActor
    func restore() async {
        errorMessage = nil
        do {
            try await AppStore.sync()
            await verifyEntitlements()
        } catch {
            errorMessage = "Restore failed. Please try again."
        }
    }

    // MARK: - Entitlement Verification

    @MainActor
    func verifyEntitlements() async {
        var activeID: String? = nil
        for await result in Transaction.currentEntitlements {
            guard let tx = try? Self.verified(result) else { continue }
            if Self.allIDs.contains(tx.productID) { activeID = tx.productID }
            await tx.finish()
        }
        setIsPremium(productID: activeID)
    }

    // MARK: - Private Helpers

    private func startTransactionListener() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let tx = try? Self.verified(result) {
                    let knownID = Self.allIDs.contains(tx.productID) ? tx.productID : nil
                    await MainActor.run { self.setIsPremium(productID: knownID) }
                    await tx.finish()
                }
            }
        }
    }

    private static func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw PremiumStoreError.failedVerification
        case .verified(let t): return t
        }
    }

    @MainActor
    private func setIsPremium(productID: String?) {
        isPremium = productID != nil
        let prefs = persistence.fetchOrCreateUserPreferences()
        prefs.premiumProductID = productID
        persistence.save()
    }
}

enum PremiumStoreError: Error {
    case failedVerification
}
