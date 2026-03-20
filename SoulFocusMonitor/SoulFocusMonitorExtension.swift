// SoulFocusMonitorExtension.swift
// DeviceActivityMonitor extension target: SoulFocusMonitor
//
// PURPOSE: This extension runs in its own process, independent of the main app.
// When a session's DeviceActivitySchedule ends (or is triggered by threshold),
// this extension fires and clears all ManagedSettings restrictions.
//
// This is the CRITICAL safety net for the app-kill edge case:
// If the user force-quits SoulFocus mid-session, the main app can't unblock apps.
// This extension guarantees apps are unblocked when the schedule expires.
//
// SETUP REQUIRED (Week 5):
//  1. Add this file to the SoulFocusMonitor target (NOT the main SoulFocus target)
//  2. Both targets must share App Group: group.com.soulfocus.shared
//  3. Add FamilyControls entitlement to BOTH targets
//  4. Register extension in Info.plist of SoulFocusMonitor target

// NOTE: FamilyControls import is commented out until the paid developer account
// and entitlement are available (Week 9). Build will succeed without it.

import Foundation
// import DeviceActivity      // Uncomment in Week 5
// import ManagedSettings     // Uncomment in Week 5

// MARK: - Activity Names
// Shared constants between main app and extension via App Group.
// Using a namespace enum keeps them type-safe.
enum SFActivityName {
    static let session = "com.soulfocus.session"  // Active session blocking schedule
}

// MARK: - Monitor Extension

// Uncomment the entire class below in Week 5 when FamilyControls entitlement is active:

/*
import DeviceActivity
import ManagedSettings

@available(iOS 16.0, *)
class SoulFocusMonitorExtension: DeviceActivityMonitor {

    /// Called when the session schedule's interval ends.
    /// This is the primary unblock mechanism when the app is alive.
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity.rawValue == SFActivityName.session {
            clearAllBlocks()
        }
    }

    /// Called when the session schedule's interval starts.
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Main app handles block activation — nothing needed here
    }

    /// Called when a usage threshold is exceeded (not used in MVP).
    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
    }

    // MARK: - Private

    private func clearAllBlocks() {
        // ManagedSettingsStore must use the shared App Group store
        let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("com.soulfocus.blocking"))
        store.clearAllSettings()
        print("[SoulFocusMonitor] All blocks cleared ✅")
    }
}
*/

// MARK: - Placeholder (remove when uncommenting above)

/// Placeholder struct so the file compiles without FamilyControls.
/// Delete this when activating the extension in Week 5.
struct SoulFocusMonitorPlaceholder {
    let note = """
    This extension enforces app unblocking when the session schedule ends.
    Activate in Week 5 by:
    1. Obtaining FamilyControls entitlement from Apple
    2. Uncomment the DeviceActivityMonitor subclass above
    3. Add correct Info.plist extension entries
    4. Test on physical device (Simulator doesn't support FamilyControls)
    """
}
