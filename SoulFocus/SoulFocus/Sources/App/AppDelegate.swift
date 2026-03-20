// AppDelegate.swift
// Handles UIKit lifecycle hooks and UNUserNotificationCenter delegate.

import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Ensure CoreData saves before app closes
        PersistenceController.shared.save()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    /// Show notification banner even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    /// Handle tap on a notification (navigate to relevant screen)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let identifier = response.notification.request.identifier
        SFLogger.info("Notification tapped — id: \(identifier)")

        // Phase 7: Route to correct screen based on notification type
        // e.g., "reminder_<UUID>" → open session setup
        // e.g., "streak_nudge" → open progress screen
    }
}
