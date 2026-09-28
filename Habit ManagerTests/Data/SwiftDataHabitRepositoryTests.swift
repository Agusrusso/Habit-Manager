import Foundation
import SwiftData
import Testing
@testable import Habit_Manager

@Suite("SwiftDataHabitRepository Integration Tests")
struct SwiftDataHabitRepositoryTests {
    
    @MainActor
    private func makeRepository() throws -> SwiftDataHabitRepository {
        let schema = Schema([Habit.self, HabitLog.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return SwiftDataHabitRepository(modelContainer: container)
    }
    
    @Test("Repository starts empty and fetches empty list")
    func emptyRepository() async throws {
        let repository = try await makeRepository()
        let habits = try await repository.getHabits()
        #expect(habits.isEmpty)
    }
    
    @Test("Saving a new habit persists it correctly")
    func saveNewHabit() async throws {
        let repository = try await makeRepository()
        let newHabit = HabitEntity(
            name: "Hacer ejercicio",
            description: "30 minutos de cardio",
            frequency: .weekly([.monday, .wednesday, .friday]),
            type: .simple
        )
        
        try await repository.saveHabit(newHabit)
        
        let fetched = try await repository.getHabits()
        #expect(fetched.count == 1)
        #expect(fetched.first?.id == newHabit.id)
        #expect(fetched.first?.name == "Hacer ejercicio")
        #expect(fetched.first?.habitDescription == "30 minutos de cardio")
        #expect(fetched.first?.frequency == .weekly([.monday, .wednesday, .friday]))
    }
    
    @Test("Saving an existing habit updates its properties")
    func updateExistingHabit() async throws {
        let repository = try await makeRepository()
        var habit = HabitEntity(name: "Leer", frequency: .daily, type: .quantitative, goal: 10, unit: "páginas")
        try await repository.saveHabit(habit)
        
        // Update habit
        habit.name = "Leer mucho"
        habit.goal = 20
        try await repository.saveHabit(habit)
        
        let fetched = try await repository.getHabit(byId: habit.id)
        #expect(fetched != nil)
        #expect(fetched?.name == "Leer mucho")
        #expect(fetched?.goal == 20)
    }
    
    @Test("Deleting a habit removes it from persistence")
    func deleteHabit() async throws {
        let repository = try await makeRepository()
        let habit = HabitEntity(name: "Meditar")
        try await repository.saveHabit(habit)
        
        #expect(try await repository.getHabits().count == 1)
        
        try await repository.deleteHabit(byId: habit.id)
        #expect(try await repository.getHabits().isEmpty)
        #expect(try await repository.getHabit(byId: habit.id) == nil)
    }
    
    @Test("Updating progress creates a new log and subsequent updates modify it")
    func updateProgress() async throws {
        let repository = try await makeRepository()
        let habit = HabitEntity(name: "Beber agua", type: .quantitative, goal: 8, unit: "vasos")
        try await repository.saveHabit(habit)
        
        let today = Date()
        
        // 1. Initial progress
        let habitWithProgress = try await repository.updateProgress(habitId: habit.id, date: today, progress: 4)
        #expect(habitWithProgress.progress(on: today) == 4)
        #expect(habitWithProgress.isCompleted(on: today) == false)
        
        // 2. Incremented progress reaching goal
        let completedHabit = try await repository.updateProgress(habitId: habit.id, date: today, progress: 8)
        #expect(completedHabit.progress(on: today) == 8)
        #expect(completedHabit.isCompleted(on: today) == true)
        
        // 3. Setting progress to 0 removes the log
        let resetHabit = try await repository.updateProgress(habitId: habit.id, date: today, progress: 0)
        #expect(resetHabit.progress(on: today) == 0)
        #expect(resetHabit.logs.isEmpty)
    }
}
