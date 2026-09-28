import Foundation
import ActivityKit

public struct HabitActivityAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public var startDate: Date
        public var endDate: Date
        public var isPaused: Bool
        public var statusMessage: String
        
        public init(
            startDate: Date,
            endDate: Date,
            isPaused: Bool = false,
            statusMessage: String = "Enfocado"
        ) {
            self.startDate = startDate
            self.endDate = endDate
            self.isPaused = isPaused
            self.statusMessage = statusMessage
        }
    }
    
    public var habitId: UUID
    public var habitName: String
    public var targetMinutes: Int
    public var habitStreak: Int
    
    public init(
        habitId: UUID,
        habitName: String,
        targetMinutes: Int,
        habitStreak: Int
    ) {
        self.habitId = habitId
        self.habitName = habitName
        self.targetMinutes = targetMinutes
        self.habitStreak = habitStreak
    }
}
