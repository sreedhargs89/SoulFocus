import Foundation
import CoreData

extension Streak {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Streak> {
        return NSFetchRequest<Streak>(entityName: "Streak")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var currentStreak: Int64
    @NSManaged public var longestStreak: Int64
    @NSManaged public var totalSessionCount: Int64
    @NSManaged public var totalMeditationSeconds: Int64
    @NSManaged public var lastSessionDate: Date?
    @NSManaged public var startDate: Date?
}
extension Streak : Identifiable {
}
