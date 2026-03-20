// UserPreferences+Extensions.swift
// Typed accessors and helpers on the UserPreferences entity.

import CoreData
import Foundation

extension UserPreferences {

    // MARK: - Typed Theme

    var appThemeID: AppThemeID {
        get { AppThemeID(rawValue: selectedTheme ?? "calm") ?? .calm }
        set { selectedTheme = newValue.rawValue }
    }

    // MARK: - Typed Session Mode

    var defaultMode: SessionMode {
        get { SessionMode(rawValue: defaultSessionMode ?? "meditation") ?? .meditation }
        set { defaultSessionMode = newValue.rawValue }
    }

    // MARK: - Trial Logic

    /// True if the user is currently within their 7-day free trial window.
    var isInTrial: Bool {
        guard let start = trialStartDate else { return false }
        let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days
        return Date().timeIntervalSince(start) < trialDuration
    }

    /// Days remaining in the free trial. Returns 0 if expired or not started.
    var trialDaysRemaining: Int {
        guard let start = trialStartDate else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        let trialDuration: TimeInterval = 7 * 24 * 60 * 60
        let remaining = trialDuration - elapsed
        return max(0, Int(ceil(remaining / 86_400)))
    }

    /// Whether the user has an active paid subscription.
    var isPremium: Bool {
        premiumProductID != nil
    }

    /// Whether the user can access premium features
    /// (either active subscription or within trial window).
    var hasPremiumAccess: Bool {
        isPremium || isInTrial
    }

    /// Call once on first launch to begin the 3-day trial clock.
    func startTrialIfNeeded() {
        guard trialStartDate == nil else { return }
        trialStartDate = Date()
    }
}
