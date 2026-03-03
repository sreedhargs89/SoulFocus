// SFLogger.swift
// Structured logging using os.Logger.
// Replaces print() everywhere — filtered by subsystem in Console.app.

import OSLog
import Foundation

enum SFLogger {

    // One logger per category — filter by category in Console.app
    private static let general  = Logger(subsystem: "com.soulfocus.app", category: "General")
    private static let coreData = Logger(subsystem: "com.soulfocus.app", category: "CoreData")
    private static let session  = Logger(subsystem: "com.soulfocus.app", category: "Session")
    private static let audio    = Logger(subsystem: "com.soulfocus.app", category: "Audio")
    private static let blocking = Logger(subsystem: "com.soulfocus.app", category: "Blocking")
    private static let store    = Logger(subsystem: "com.soulfocus.app", category: "StoreKit")

    // MARK: - General
    static func info(_ message: String)  { general.info("\(message, privacy: .public)") }
    static func debug(_ message: String) { general.debug("\(message, privacy: .public)") }
    static func error(_ message: String) { general.error("\(message, privacy: .public)") }

    // MARK: - Domain-specific
    static func coreData(_ message: String)  { coreData.debug("\(message, privacy: .public)") }
    static func session(_ message: String)   { session.info("\(message, privacy: .public)") }
    static func audio(_ message: String)     { audio.debug("\(message, privacy: .public)") }
    static func blocking(_ message: String)  { blocking.info("\(message, privacy: .public)") }
    static func storeKit(_ message: String)  { store.info("\(message, privacy: .public)") }
}
