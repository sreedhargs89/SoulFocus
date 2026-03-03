# SoulFocus — Xcode Project Setup Guide

All source files are pre-written and waiting in `/Users/sree/dev/SoulFocus/Sources/`.
Follow these steps once to wire them into a working Xcode project.

---

## Step 1 — Create the Xcode Project

1. Open **Xcode → File → New → Project**
2. Choose **iOS → App** → click Next
3. Fill in:
   - **Product Name:** `SoulFocus`
   - **Bundle Identifier:** `com.soulfocus.app`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None (we use CoreData manually)
   - Uncheck "Include Tests" for now (we add them separately)
4. **Save Location:** `/Users/sree/dev/SoulFocus/`
   - Xcode will create `/Users/sree/dev/SoulFocus/SoulFocus.xcodeproj`

---

## Step 2 — Delete Xcode's Auto-Generated Files

Xcode generates placeholder files. Replace them with ours:

In the **Project Navigator**, delete these files (move to Trash):
- `SoulFocus/ContentView.swift`
- `SoulFocus/SoulFocusApp.swift`
- `SoulFocus/Assets.xcassets` (keep it if you want — we'll add assets later)

---

## Step 3 — Add Source Files to the Project

1. In Project Navigator, **right-click** the `SoulFocus` group (yellow folder)
2. Choose **"Add Files to SoulFocus…"**
3. Navigate to `/Users/sree/dev/SoulFocus/Sources/`
4. Select **all folders and files**
5. Ensure:
   - ✅ "Copy items if needed" is **CHECKED**
   - ✅ "Create groups" is selected
   - Target Membership: **SoulFocus** ✅
6. Click **Add**

> The `SoulFocus.xcdatamodeld` file must be in the SoulFocus target. Xcode will auto-detect it.

---

## Step 4 — Add the Monitor Extension Target

1. **File → New → Target**
2. Choose **iOS → Other → DeviceActivityMonitor Extension**
   - If you don't see it, search "DeviceActivity"
3. Product Name: `SoulFocusMonitor`
4. Click Finish → Activate scheme if prompted

5. Add `SoulFocusMonitor/SoulFocusMonitorExtension.swift` to the **SoulFocusMonitor** target:
   - Right-click SoulFocusMonitor group → Add Files → select the file
   - Target membership: **SoulFocusMonitor only** (NOT SoulFocus main)

---

## Step 5 — Add Unit Test Target

1. **File → New → Target → Unit Testing Bundle**
2. Name: `SoulFocusTests`
3. Add `SoulFocusTests/PersistenceControllerTests.swift` to this target
4. In test target **Build Settings** → set `@testable import SoulFocus`

---

## Step 6 — Configure Capabilities (Main App Target)

Select the **SoulFocus** project → **SoulFocus target** → **Signing & Capabilities**:

1. Sign in with your **Apple ID** (free account works for local development)
2. Set Team to your personal team

Add these capabilities (click **+ Capability**):
- **HealthKit** — needed for Mindful Minutes (Week 7)

> **App Groups** and **Family Controls** require a paid developer account.
> Leave them out for now — we'll add them in Week 5/9 when the account is ready.

---

## Step 7 — Set Deployment Target

1. Select **SoulFocus** project → **SoulFocus target** → **General**
2. Set **Minimum Deployments** → **iOS 16.1**

Repeat for **SoulFocusMonitor** target.

---

## Step 8 — Configure CoreData Model

1. In Project Navigator, click `SoulFocus.xcdatamodeld`
2. For each entity, verify **Codegen** is set to **"Class Definition"**
   (Editor → Data Model Inspector panel → Codegen dropdown)
3. This tells Xcode to auto-generate the NSManagedObject subclasses — no manual class files needed

---

## Step 9 — Enable Swift 6 Strict Concurrency

1. Select **SoulFocus** target → **Build Settings**
2. Search for `SWIFT_STRICT_CONCURRENCY`
3. Set to **`complete`** (not just "minimal")

Do the same for **SoulFocusMonitor** and **SoulFocusTests**.

> This catches concurrency bugs at compile time. Fix any errors as you go — do NOT set to "minimal" and defer.

---

## Step 10 — Build and Run

1. Select **SoulFocus** scheme
2. Choose **iPhone 16 Simulator** (or any iOS 16.1+ simulator)
3. Press **⌘R** to build and run

### Expected Result ✅
- App launches with the SoulFocus placeholder home screen
- 4 tabs visible: Home, Progress, Journal, Settings
- No build errors or warnings (except possible Swift 6 concurrency notes — fix immediately)

---

## Step 11 — Run Unit Tests

1. Press **⌘U** to run all tests
2. All tests in `PersistenceControllerTests` should pass ✅

---

## Troubleshooting

| Error | Fix |
|---|---|
| `No such module 'SoulFocus'` in tests | Ensure test target has `@testable import SoulFocus` and SoulFocus is a dependency |
| `SoulFocus.xcdatamodeld not found` | Ensure the `.xcdatamodeld` package is added to the SoulFocus target (check target membership) |
| `SessionMode not found` | `MeditationSession+Extensions.swift` must be in the SoulFocus target |
| `AppContainer not found` | `AppContainer.swift` must be in the SoulFocus target |
| Strict concurrency errors | Fix with `@MainActor`, `Sendable`, or `actor` — don't suppress |

---

## File → Target Membership Quick Reference

| File | SoulFocus | SoulFocusMonitor | SoulFocusTests |
|---|---|---|---|
| Everything in `Sources/` | ✅ | ❌ | ❌ |
| `SoulFocusMonitorExtension.swift` | ❌ | ✅ | ❌ |
| `PersistenceControllerTests.swift` | ❌ | ❌ | ✅ |

---

## What's Next (Week 2)

With Week 1 foundation complete, Week 2 builds:
- `SessionManager.swift` — timer, state machine, CoreData writes
- `SessionSetupView.swift` — mode picker, duration selector
- `ActiveSessionView.swift` — countdown ring, controls
- `SessionCompleteView.swift` — mood capture, streak animation
- Apply for FamilyControls entitlement at developer.apple.com
