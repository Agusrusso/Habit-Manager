import Foundation
@testable import Habit_Manager

actor MockFocusSessionService: FocusSessionServiceProtocol {
    var startedSessions: [(habitId: UUID, habitName: String, duration: Int)] = []
    var endedSessions: [String] = []
    var activeSessions: [UUID: String] = [:]
    
    func startFocusSession(habitId: UUID, habitName: String, streak: Int, durationMinutes: Int) async throws -> String? {
        startedSessions.append((habitId, habitName, durationMinutes))
        let id = "mock_activity_\(UUID().uuidString)"
        activeSessions[habitId] = id
        return id
    }
    
    func updateFocusSession(activityId: String, isPaused: Bool, statusMessage: String) async {}
    
    func endFocusSession(activityId: String) async {
        endedSessions.append(activityId)
        if let habitId = activeSessions.first(where: { $0.value == activityId })?.key {
            activeSessions.removeValue(forKey: habitId)
        }
    }
    
    func activeSessionId(for habitId: UUID) async -> String? {
        activeSessions[habitId]
    }
    
    func hasActiveSession(for habitId: UUID) async -> Bool {
        activeSessions[habitId] != nil
    }
}
