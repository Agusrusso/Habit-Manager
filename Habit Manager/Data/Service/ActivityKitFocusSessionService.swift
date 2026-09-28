import Foundation
import ActivityKit

public actor ActivityKitFocusSessionService: FocusSessionServiceProtocol {
    private var activeSessions: [UUID: String] = [:]
    
    public init() {}
    
    public func startFocusSession(
        habitId: UUID,
        habitName: String,
        streak: Int,
        durationMinutes: Int
    ) async throws -> String? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return nil
        }
        
        // End any preexisting session for this habit
        if let existingId = activeSessions[habitId] {
            await endFocusSession(activityId: existingId)
        }
        
        let attributes = HabitActivityAttributes(
            habitId: habitId,
            habitName: habitName,
            targetMinutes: durationMinutes,
            habitStreak: streak
        )
        
        let startDate = Date.now
        let endDate = startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
        
        let initialState = HabitActivityAttributes.ContentState(
            startDate: startDate,
            endDate: endDate,
            isPaused: false,
            statusMessage: "Enfocado"
        )
        
        let content = ActivityContent(state: initialState, staleDate: endDate.addingTimeInterval(60))
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            activeSessions[habitId] = activity.id
            return activity.id
        } catch {
            return nil
        }
    }
    
    public func updateFocusSession(activityId: String, isPaused: Bool, statusMessage: String) async {
        guard let activity = Activity<HabitActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
            return
        }
        
        var currentState = activity.content.state
        currentState.isPaused = isPaused
        currentState.statusMessage = statusMessage
        
        let updatedContent = ActivityContent(state: currentState, staleDate: nil)
        await activity.update(updatedContent)
    }
    
    public func endFocusSession(activityId: String) async {
        // Find and clean up tracking
        if let habitId = activeSessions.first(where: { $0.value == activityId })?.key {
            activeSessions.removeValue(forKey: habitId)
        }
        
        guard let activity = Activity<HabitActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
            return
        }
        
        var finalState = activity.content.state
        finalState.statusMessage = "¡Sesión finalizada!"
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        await activity.end(finalContent, dismissalPolicy: .immediate)
    }
    
    public func activeSessionId(for habitId: UUID) async -> String? {
        activeSessions[habitId]
    }
    
    public func hasActiveSession(for habitId: UUID) async -> Bool {
        activeSessions[habitId] != nil
    }
}
