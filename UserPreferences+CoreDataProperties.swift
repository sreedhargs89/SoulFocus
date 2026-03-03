import Foundation
import CoreData

extension UserPreferences {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var selectedTheme: String?
    @NSManaged public var defaultSessionMode: String?
    @NSManaged public var defaultDurationSeconds: Int32
    @NSManaged public var hasCompletedOnboarding: Bool
    @NSManaged public var hasRequestedHealthKit: Bool
    @NSManaged public var distractionBlockingEnabled: Bool
    @NSManaged public var appOpenCount: Int64
    @NSManaged public var trialStartDate: Date?
    @NSManaged public var premiumProductID: String?
}
extension UserPreferences : Identifiable {
}
