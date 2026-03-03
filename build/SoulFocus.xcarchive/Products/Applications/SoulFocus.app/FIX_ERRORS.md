# 🔧 QUICK FIX GUIDE - Core Data Errors

## ✅ Files Just Created/Fixed

I've just created these Core Data entity files:

1. ✅ `MeditationSession+CoreDataClass.swift`
2. ✅ `MeditationSession+CoreDataProperties.swift`
3. ✅ `Streak+CoreDataClass.swift`
4. ✅ `Streak+CoreDataProperties.swift`
5. ✅ `UserPreferences+CoreDataClass.swift`
6. ✅ `UserPreferences+CoreDataProperties.swift`

And added imports:
- ✅ Added `import CoreData` to `ContentView.swift`
- ✅ Added `import SwiftUI` to `AppContainer.swift`

---

## 🚨 TO FIX THE ERRORS IN XCODE:

### Step 1: Add Files to Your Target

**The Core Data files need to be added to your Xcode project!**

1. **In Xcode, in the Project Navigator (left sidebar)**
2. **Right-click** on your project folder
3. **Select "Add Files to [ProjectName]..."**
4. **Navigate to your repo folder**
5. **Select these 6 files** (hold ⌘ to select multiple):
   - `MeditationSession+CoreDataClass.swift`
   - `MeditationSession+CoreDataProperties.swift`
   - `Streak+CoreDataClass.swift`
   - `Streak+CoreDataProperties.swift`
   - `UserPreferences+CoreDataClass.swift`
   - `UserPreferences+CoreDataProperties.swift`

6. **Make sure "Add to targets" checkbox is checked** for your app
7. **Click "Add"**

### Step 2: Clean Build Folder

```
⌘⇧K (Clean Build Folder)
```

### Step 3: Build

```
⌘B (Build)
```

**All errors should now be gone!** ✅

---

## 🎯 Alternative: Use Xcode's Core Data Model Generator

If the manual approach doesn't work, try this:

### 1. Create the Core Data Model in Xcode

1. **File → New → File**
2. Select **Data Model** (under Core Data section)
3. Name it **SoulFocus** (must match exactly!)
4. Click **Create**

### 2. Add Entities

In the `.xcdatamodeld` file that opens:

#### Entity 1: MeditationSession
- Click **Add Entity** (bottom toolbar)
- Name it **MeditationSession**
- Add attributes (click + under Attributes):
  - `id` → UUID
  - `mode` → String
  - `startTime` → Date
  - `durationPlanned` → Integer 32
  - `durationActual` → Integer 32
  - `wasCompleted` → Boolean
  - `wasInterrupted` → Boolean
  - `distractionBlockingEnabled` → Boolean
  - `moodBefore` → Integer 16
  - `moodAfter` → Integer 16
  - `journalNotes` → String (optional)
  - `audioTrackID` → String (optional)

#### Entity 2: Streak
- Click **Add Entity**
- Name it **Streak**
- Add attributes:
  - `id` → UUID
  - `currentStreak` → Integer 64
  - `longestStreak` → Integer 64
  - `totalSessionCount` → Integer 64
  - `totalMeditationSeconds` → Integer 64
  - `lastSessionDate` → Date (optional)
  - `startDate` → Date (optional)

#### Entity 3: UserPreferences
- Click **Add Entity**
- Name it **UserPreferences**
- Add attributes:
  - `id` → UUID
  - `selectedTheme` → String
  - `defaultSessionMode` → String
  - `defaultDurationSeconds` → Integer 32
  - `hasCompletedOnboarding` → Boolean
  - `hasRequestedHealthKit` → Boolean
  - `distractionBlockingEnabled` → Boolean
  - `appOpenCount` → Integer 64
  - `trialStartDate` → Date (optional)
  - `premiumProductID` → String (optional)

### 3. Generate Classes

1. **Select the Data Model** in Project Navigator
2. **Editor → Create NSManagedObject Subclass**
3. **Select your model** (SoulFocus)
4. **Select all 3 entities**
5. **Click Next → Create**

OR set **Codegen** to **"Class Definition"** for each entity in the Data Model Inspector.

### 4. Delete my manual files if using Xcode generation

If you used Xcode's generator, delete these files I created:
- All `+CoreDataClass.swift` files
- All `+CoreDataProperties.swift` files

---

## ✅ Verification Checklist

After adding files, verify:

```
□ All 6 Core Data files are in Project Navigator
□ Each file shows target membership in File Inspector (⌘⌥1)
□ SoulFocus.xcdatamodeld exists (or was created)
□ Clean build completed (⌘⇧K)
□ Build succeeds (⌘B) with 0 errors
□ No "Cannot find 'MeditationSession'" errors
□ No "Cannot find 'Streak'" errors
□ No "Cannot find 'UserPreferences'" errors
□ AppContainer conforms to ObservableObject (no errors)
```

---

## 🐛 Still Getting Errors?

### Error: "Cannot find type in scope"
**Fix:** The files aren't in your target
- Select each file in Project Navigator
- Open File Inspector (⌘⌥1)
- Check "Target Membership" for your app

### Error: "Duplicate symbols"
**Fix:** You have both manual files AND Xcode-generated classes
- Choose ONE method (manual files OR Xcode generation)
- Delete the other set

### Error: "Entity not found in model"
**Fix:** Model name mismatch
- Verify `NSPersistentContainer(name: "SoulFocus")` matches your `.xcdatamodeld` filename exactly

### Error: ObservableObject conformance
**Fix:** Import SwiftUI
- Already fixed in AppContainer.swift ✅

---

## 🎯 Quick Test After Fix

Once errors are gone, test with this in `ContentView.swift`:

```swift
.onAppear {
    let prefs = container.persistence.fetchOrCreateUserPreferences()
    print("✅ UserPreferences works! Open count: \(prefs.appOpenCount)")
    
    let streak = container.persistence.fetchOrCreateStreak()
    print("✅ Streak works! Current: \(streak.currentStreak)")
}
```

If those print statements work, everything is fixed! 🎉

---

## 📝 Summary

**What was wrong:**
- Core Data entity class files weren't in your Xcode target
- Missing some imports

**What I fixed:**
- ✅ Created all 6 Core Data entity files
- ✅ Added proper imports to ContentView and AppContainer

**What you need to do:**
1. Add the 6 new files to your Xcode project target
2. Clean build (⌘⇧K)
3. Build (⌘B)
4. Run (⌘R)

**That's it!** Your app should now build successfully! 🚀

---

Need more help? Check if files are in target:
1. Click on any file in Project Navigator
2. Open File Inspector (right sidebar, or ⌘⌥1)
3. Look at "Target Membership" section
4. Make sure your app target is checked ✅
