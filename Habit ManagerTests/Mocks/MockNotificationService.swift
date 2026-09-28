import Foundation
@testable import Habit_Manager

public actor MockNotificationService: NotificationServiceProtocol {
    public var authorized: Bool
    public var scheduledHabits: [UUID: HabitEntity] = [:]
    public var cancelledHabitIds: [UUID] = []
    
    public init(authorized: Bool = true) {
        self.authorized = authorized
    }
    
    public func requestAuthorization() async -> Bool {
        authorized
    }
    
    public func scheduleNotification(for habit: HabitEntity) async {
        scheduledHabits[habit.id] = habit
    }
    
    public func cancelNotification(for habitId: UUID) async {
        scheduledHabits.removeValue(forKey: habitId)
        cancelledHabitIds.append(habitId)
    }
}
