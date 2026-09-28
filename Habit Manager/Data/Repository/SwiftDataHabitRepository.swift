import Foundation
import SwiftData

@MainActor
public final class SwiftDataHabitRepository: HabitRepositoryProtocol {
    private let modelContainer: ModelContainer?
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContainer = nil
        self.modelContext = modelContext
    }
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    public func getHabits() async throws -> [HabitEntity] {
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        let habits = try modelContext.fetch(descriptor)
        return habits.map { $0.toEntity() }
    }
    
    public func getHabit(byId id: UUID) async throws -> HabitEntity? {
        let habit = try findHabitModel(byId: id)
        return habit?.toEntity()
    }
    
    public func saveHabit(_ habit: HabitEntity) async throws {
        if let existing = try findHabitModel(byId: habit.id) {
            existing.update(from: habit)
        } else {
            let newHabit = Habit(from: habit)
            modelContext.insert(newHabit)
        }
        try modelContext.save()
    }
    
    public func deleteHabit(byId id: UUID) async throws {
        if let habitToDelete = try findHabitModel(byId: id) {
            modelContext.delete(habitToDelete)
            try modelContext.save()
        }
    }
    
    public func updateProgress(habitId: UUID, date: Date, progress: Int) async throws -> HabitEntity {
        guard let habit = try findHabitModel(byId: habitId) else {
            throw HabitDomainError.habitNotFound(habitId)
        }
        
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        if habit.logs == nil {
            habit.logs = []
        }
        
        if let existingLog = habit.logs?.first(where: { calendar.isDate($0.date, inSameDayAs: targetDate) }) {
            if progress <= 0 {
                if let index = habit.logs?.firstIndex(where: { $0 === existingLog }) {
                    habit.logs?.remove(at: index)
                }
                modelContext.delete(existingLog)
            } else {
                existingLog.progress = progress
            }
        } else if progress > 0 {
            let newLog = HabitLog(date: targetDate, progress: progress)
            newLog.habit = habit
            habit.logs?.append(newLog)
        }
        
        try modelContext.save()
        return habit.toEntity()
    }
    
    private func findHabitModel(byId id: UUID) throws -> Habit? {
        var descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
