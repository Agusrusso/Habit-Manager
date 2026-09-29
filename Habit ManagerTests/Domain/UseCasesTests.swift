import Foundation
import Testing
@testable import Habit_Manager

@Suite("Domain Use Cases Tests")
struct UseCasesTests {
    private let calendar = Calendar.current
    
    @Test("GetHabitsUseCase retrieves all habits from repository")
    func getHabitsRetrievesAll() async throws {
        let habit1 = HabitEntity(name: "Hábito 1")
        let habit2 = HabitEntity(name: "Hábito 2")
        let repository = MockHabitRepository(initialHabits: [habit1, habit2])
        let useCase = GetHabitsUseCase(repository: repository)
        
        let habits = try await useCase.execute()
        #expect(habits.count == 2)
    }
    
    @Test("GetTodaysHabitsUseCase filters only scheduled habits")
    func getTodaysHabitsFiltersCorrectly() async throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 28
        let monday = calendar.date(from: components)!
        
        let dailyHabit = HabitEntity(name: "Diario", frequency: .daily)
        let mondayHabit = HabitEntity(name: "Lunes", frequency: .weekly([.monday]))
        let sundayHabit = HabitEntity(name: "Domingo", frequency: .weekly([.sunday]))
        
        let repository = MockHabitRepository(initialHabits: [dailyHabit, mondayHabit, sundayHabit])
        let useCase = GetTodaysHabitsUseCase(repository: repository, calendar: calendar)
        
        let scheduledToday = try await useCase.execute(for: monday)
        #expect(scheduledToday.count == 2)
        #expect(scheduledToday.contains { $0.name == "Diario" })
        #expect(scheduledToday.contains { $0.name == "Lunes" })
        #expect(!scheduledToday.contains { $0.name == "Domingo" })
    }
    
    @Test("ToggleHabitCompletionUseCase toggles simple habit")
    func toggleHabitCompletionSimple() async throws {
        let habit = HabitEntity(name: "Meditar", type: .simple)
        let repository = MockHabitRepository(initialHabits: [habit])
        let useCase = ToggleHabitCompletionUseCase(repository: repository, calendar: calendar)
        let today = Date()
        
        let completedHabit = try await useCase.execute(habitId: habit.id, on: today)
        #expect(completedHabit.isCompleted(on: today, calendar: calendar) == true)
        #expect(completedHabit.progress(on: today, calendar: calendar) == 1)
        
        let uncompletedHabit = try await useCase.execute(habitId: habit.id, on: today)
        #expect(uncompletedHabit.isCompleted(on: today, calendar: calendar) == false)
        #expect(uncompletedHabit.progress(on: today, calendar: calendar) == 0)
    }
    
    @Test("ToggleHabitCompletionUseCase setProgress updates quantitative habit")
    func setProgressQuantitative() async throws {
        let habit = HabitEntity(name: "Agua", type: .quantitative, goal: 8, unit: "vasos")
        let repository = MockHabitRepository(initialHabits: [habit])
        let useCase = ToggleHabitCompletionUseCase(repository: repository, calendar: calendar)
        let today = Date()
        
        let updated5 = try await useCase.setProgress(habitId: habit.id, on: today, progress: 5)
        #expect(updated5.progress(on: today, calendar: calendar) == 5)
        #expect(updated5.isCompleted(on: today, calendar: calendar) == false)
        
        let updated8 = try await useCase.setProgress(habitId: habit.id, on: today, progress: 8)
        #expect(updated8.progress(on: today, calendar: calendar) == 8)
        #expect(updated8.isCompleted(on: today, calendar: calendar) == true)
    }
    
    @Test("SaveHabitUseCase saves and schedules reminder if enabled")
    func saveHabitSchedulesNotification() async throws {
        let repository = MockHabitRepository()
        let notificationService = MockNotificationService()
        let useCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        
        let habit = HabitEntity(name: "Leer", reminderEnabled: true, reminderTime: Date())
        try await useCase.execute(habit)
        
        let savedHabits = try await repository.getHabits()
        let scheduledMap = await notificationService.scheduledHabits
        
        #expect(savedHabits.count == 1)
        #expect(scheduledMap[habit.id] != nil)
    }
    
    @Test("SaveHabitUseCase cancels reminder if disabled")
    func saveHabitCancelsNotificationIfDisabled() async throws {
        let repository = MockHabitRepository()
        let notificationService = MockNotificationService()
        let useCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        
        let habit = HabitEntity(name: "Leer", reminderEnabled: false)
        try await useCase.execute(habit)
        
        let cancelledIds = await notificationService.cancelledHabitIds
        #expect(cancelledIds.contains(habit.id))
    }
    
    @Test("SaveHabitUseCase throws error on empty name")
    func saveHabitThrowsOnEmptyName() async throws {
        let repository = MockHabitRepository()
        let notificationService = MockNotificationService()
        let useCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        
        let habit = HabitEntity(name: "   ")
        
        await #expect(throws: HabitDomainError.self) {
            try await useCase.execute(habit)
        }
    }
    
    @Test("DeleteHabitUseCase deletes habit and cancels notification")
    func deleteHabitRemovesAndCancels() async throws {
        let habit = HabitEntity(name: "Correr")
        let repository = MockHabitRepository(initialHabits: [habit])
        let notificationService = MockNotificationService()
        let useCase = DeleteHabitUseCase(repository: repository, notificationService: notificationService)
        
        try await useCase.execute(habitId: habit.id)
        
        let habits = try await repository.getHabits()
        let cancelledIds = await notificationService.cancelledHabitIds
        
        #expect(habits.isEmpty)
        #expect(cancelledIds.contains(habit.id))
    }
}
