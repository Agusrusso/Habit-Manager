import Foundation
import Testing
@testable import Habit_Manager

@Suite("HabitListViewModel Tests")
struct HabitListViewModelTests {
    
    @Test("HabitListViewModel loads all habits")
    @MainActor
    func loadAllHabits() async {
        let habit1 = HabitEntity(name: "Hábito 1")
        let habit2 = HabitEntity(name: "Hábito 2")
        let repository = MockHabitRepository(initialHabits: [habit1, habit2])
        let notificationService = MockNotificationService()
        let getHabitsUseCase = GetHabitsUseCase(repository: repository)
        let deleteHabitUseCase = DeleteHabitUseCase(repository: repository, notificationService: notificationService)
        
        let viewModel = HabitListViewModel(
            getHabitsUseCase: getHabitsUseCase,
            deleteHabitUseCase: deleteHabitUseCase
        )
        
        await viewModel.loadHabits()
        #expect(viewModel.habits.count == 2)
    }
    
    @Test("HabitListViewModel deletes habit")
    @MainActor
    func deleteHabit() async {
        let habit1 = HabitEntity(name: "Hábito 1")
        let habit2 = HabitEntity(name: "Hábito 2")
        let repository = MockHabitRepository(initialHabits: [habit1, habit2])
        let notificationService = MockNotificationService()
        let getHabitsUseCase = GetHabitsUseCase(repository: repository)
        let deleteHabitUseCase = DeleteHabitUseCase(repository: repository, notificationService: notificationService)
        
        let viewModel = HabitListViewModel(
            getHabitsUseCase: getHabitsUseCase,
            deleteHabitUseCase: deleteHabitUseCase
        )
        
        await viewModel.loadHabits()
        await viewModel.deleteHabit(habit1)
        
        #expect(viewModel.habits.count == 1)
        #expect(viewModel.habits.first?.id == habit2.id)
    }
}
