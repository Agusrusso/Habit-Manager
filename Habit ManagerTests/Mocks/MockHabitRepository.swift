import Foundation
@testable import Habit_Manager

public actor MockHabitRepository: HabitRepositoryProtocol {
    public var habits: [UUID: HabitEntity] = [:]
    
    public init(initialHabits: [HabitEntity] = []) {
        for habit in initialHabits {
            self.habits[habit.id] = habit
        }
    }
    
    public func getHabits() async throws -> [HabitEntity] {
        Array(habits.values).sorted { $0.creationDate > $1.creationDate }
    }
    
    public func getHabit(byId id: UUID) async throws -> HabitEntity? {
        habits[id]
    }
    
    public func saveHabit(_ habit: HabitEntity) async throws {
        habits[habit.id] = habit
    }
    
    public func deleteHabit(byId id: UUID) async throws {
        habits.removeValue(forKey: id)
    }
    
    public func updateProgress(habitId: UUID, date: Date, progress: Int) async throws -> HabitEntity {
        guard var habit = habits[habitId] else {
            throw HabitDomainError.habitNotFound(habitId)
        }
        
        let calendar = Calendar.current
        var logs = habit.logs
        if let index = logs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            if progress == 0 {
                logs.remove(at: index)
            } else {
                logs[index].progress = progress
            }
        } else if progress > 0 {
            logs.append(HabitLogEntity(date: date, progress: progress))
        }
        
        habit.logs = logs
        habits[habitId] = habit
        return habit
    }
}
