import Foundation
import CoreData

extension MeditationSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeditationSession> {
        return NSFetchRequest<MeditationSession>(entityName: "MeditationSession")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var mode: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var durationPlanned: Int32
    @NSManaged public var durationActual: Int32
    @NSManaged public var wasCompleted: Bool
    @NSManaged public var wasInterrupted: Bool
    @NSManaged public var distractionBlockingEnabled: Bool
    @NSManaged public var moodBefore: Int16
    @NSManaged public var moodAfter: Int16
    @NSManaged public var journalNotes: String?
    @NSManaged public var audioTrackID: String?
}
extension MeditationSession : Identifiable {
}
