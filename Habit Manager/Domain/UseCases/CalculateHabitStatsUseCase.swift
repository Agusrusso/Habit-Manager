import Foundation

public struct HabitStatsSummary: Sendable, Equatable, Identifiable {
    public var id: UUID { habitId }
    public let habitId: UUID
    public let habitName: String
    public let streak: Int
    public let weeklyCompletionPercentage: Double
    public let monthlyCompletionPercentage: Double
    
    public init(
        habitId: UUID,
        habitName: String,
        streak: Int,
        weeklyCompletionPercentage: Double,
        monthlyCompletionPercentage: Double
    ) {
        self.habitId = habitId
        self.habitName = habitName
        self.streak = streak
        self.weeklyCompletionPercentage = weeklyCompletionPercentage
        self.monthlyCompletionPercentage = monthlyCompletionPercentage
    }
}

public protocol CalculateHabitStatsUseCaseProtocol: Sendable {
    func execute(for habit: HabitEntity, referenceDate: Date) -> HabitStatsSummary
    func execute(for habits: [HabitEntity], referenceDate: Date) -> [HabitStatsSummary]
}

public struct CalculateHabitStatsUseCase: CalculateHabitStatsUseCaseProtocol {
    private let calendar: Calendar
    
    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    public func execute(for habit: HabitEntity, referenceDate: Date = .now) -> HabitStatsSummary {
        let streak = habit.currentStreak(at: referenceDate, calendar: calendar)
        let weeklyPercentage = habit.completionPercentage(forLast: 7, endingAt: referenceDate, calendar: calendar)
        let monthlyPercentage = habit.completionPercentage(forLast: 30, endingAt: referenceDate, calendar: calendar)
        
        return HabitStatsSummary(
            habitId: habit.id,
            habitName: habit.name,
            streak: streak,
            weeklyCompletionPercentage: weeklyPercentage,
            monthlyCompletionPercentage: monthlyPercentage
        )
    }
    
    public func execute(for habits: [HabitEntity], referenceDate: Date = .now) -> [HabitStatsSummary] {
        habits.map { execute(for: $0, referenceDate: referenceDate) }
    }
}
