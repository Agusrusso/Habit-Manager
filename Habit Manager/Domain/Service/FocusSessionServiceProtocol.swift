import Foundation

public protocol FocusSessionServiceProtocol: Sendable {
    /// Starts a live activity focus session and returns the activity ID if started.
    func startFocusSession(habitId: UUID, habitName: String, streak: Int, durationMinutes: Int) async throws -> String?
    
    /// Updates an existing focus session (e.g. pause/resume or update status message).
    func updateFocusSession(activityId: String, isPaused: Bool, statusMessage: String) async
    
    /// Ends the focus session.
    func endFocusSession(activityId: String) async
    
    /// Returns the active activity ID for a given habit, if any.
    func activeSessionId(for habitId: UUID) async -> String?
    
    /// Returns whether there is an active focus session for this habit.
    func hasActiveSession(for habitId: UUID) async -> Bool
}
