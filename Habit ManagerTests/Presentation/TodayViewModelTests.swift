import Foundation
import Testing
@testable import Habit_Manager

@Suite("TodayViewModel Tests")
struct TodayViewModelTests {
    private let calendar = Calendar.current
    
    @Test("TodayViewModel loads only scheduled habits")
    @MainActor
    func loadScheduledHabits() async {
        let habit1 = HabitEntity(name: "Diario", frequency: .daily)
        let habit2 = HabitEntity(name: "Semanal", frequency: .weekly([.sunday]))
        
        // Pick a Monday
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 9
        comps.day = 28 // Monday
        let monday = calendar.date(from: comps)!
        
        let repository = MockHabitRepository(initialHabits: [habit1, habit2])
        let getTodaysUseCase = GetTodaysHabitsUseCase(repository: repository, calendar: calendar)
        let toggleUseCase = ToggleHabitCompletionUseCase(repository: repository, calendar: calendar)
        
        let viewModel = TodayViewModel(
            getTodaysHabitsUseCase: getTodaysUseCase,
            toggleHabitCompletionUseCase: toggleUseCase,
            calendar: calendar
        )
        
        await viewModel.loadHabits(for: monday)
        
        #expect(viewModel.habits.count == 1)
        #expect(viewModel.habits.first?.name == "Diario")
    }
    
    @Test("TodayViewModel toggles habit completion")
    @MainActor
    func toggleHabitCompletion() async {
        let habit = HabitEntity(name: "Meditar", type: .simple)
        let repository = MockHabitRepository(initialHabits: [habit])
        let getTodaysUseCase = GetTodaysHabitsUseCase(repository: repository, calendar: calendar)
        let toggleUseCase = ToggleHabitCompletionUseCase(repository: repository, calendar: calendar)
        
        let viewModel = TodayViewModel(
            getTodaysHabitsUseCase: getTodaysUseCase,
            toggleHabitCompletionUseCase: toggleUseCase,
            calendar: calendar
        )
        
        let today = Date()
        await viewModel.loadHabits(for: today)
        
        #expect(viewModel.habits.first?.isCompleted(on: today) == false)
        
        await viewModel.toggleCompletion(for: habit, on: today)
        #expect(viewModel.habits.first?.isCompleted(on: today) == true)
        
        await viewModel.toggleCompletion(for: habit, on: today)
        #expect(viewModel.habits.first?.isCompleted(on: today) == false)
    }
    
    @Test("TodayViewModel sets progress for quantitative habit")
    @MainActor
    func setProgressQuantitative() async {
        let habit = HabitEntity(name: "Agua", type: .quantitative, goal: 8, unit: "vasos")
        let repository = MockHabitRepository(initialHabits: [habit])
        let getTodaysUseCase = GetTodaysHabitsUseCase(repository: repository, calendar: calendar)
        let toggleUseCase = ToggleHabitCompletionUseCase(repository: repository, calendar: calendar)
        
        let viewModel = TodayViewModel(
            getTodaysHabitsUseCase: getTodaysUseCase,
            toggleHabitCompletionUseCase: toggleUseCase,
            calendar: calendar
        )
        
        let today = Date()
        await viewModel.loadHabits(for: today)
        
        await viewModel.setProgress(for: habit, progress: 4, on: today)
        #expect(viewModel.habits.first?.progress(on: today) == 4)
        #expect(viewModel.habits.first?.isCompleted(on: today) == false)
        
        await viewModel.setProgress(for: habit, progress: 8, on: today)
        #expect(viewModel.habits.first?.progress(on: today) == 8)
        #expect(viewModel.habits.first?.isCompleted(on: today) == true)
    }
    
    @Test("TodayViewModel starts and ends focus session with completion")
    @MainActor
    func startAndEndFocusSession() async {
        let habit = HabitEntity(name: "Lectura", type: .simple)
        let repository = MockHabitRepository(initialHabits: [habit])
        let getTodaysUseCase = GetTodaysHabitsUseCase(repository: repository, calendar: calendar)
        let toggleUseCase = ToggleHabitCompletionUseCase(repository: repository, calendar: calendar)
        let mockFocusService = MockFocusSessionService()
        
        let viewModel = TodayViewModel(
            getTodaysHabitsUseCase: getTodaysUseCase,
            toggleHabitCompletionUseCase: toggleUseCase,
            focusSessionService: mockFocusService,
            calendar: calendar
        )
        
        let today = Date()
        await viewModel.loadHabits(for: today)
        
        // Start focus session
        await viewModel.startFocusSession(for: habit, durationMinutes: 25, on: today)
        #expect(viewModel.activeFocusHabitIds.contains(habit.id))
        
        let startedSessions = await mockFocusService.startedSessions
        #expect(startedSessions.count == 1)
        #expect(startedSessions.first?.habitName == "Lectura")
        #expect(startedSessions.first?.duration == 25)
        
        // Check active sessions
        await viewModel.checkActiveFocusSessions()
        #expect(viewModel.activeFocusHabitIds.contains(habit.id))
        
        // End focus session and complete habit
        await viewModel.endFocusSession(for: habit, markCompleted: true, on: today)
        #expect(viewModel.activeFocusHabitIds.contains(habit.id) == false)
        #expect(viewModel.habits.first?.isCompleted(on: today) == true)
        
        let endedSessions = await mockFocusService.endedSessions
        #expect(endedSessions.count == 1)
    }
}

