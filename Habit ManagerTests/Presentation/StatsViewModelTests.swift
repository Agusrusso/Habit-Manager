import Foundation
import Testing
@testable import Habit_Manager

@Suite("StatsViewModel Tests")
struct StatsViewModelTests {
    
    @Test("StatsViewModel computes stats and filters active streaks")
    @MainActor
    func statsComputation() async {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Habit with streak
        let habit1 = HabitEntity(
            name: "Hábito con racha",
            logs: [HabitLogEntity(date: today, progress: 1)]
        )
        // Habit without streak
        let habit2 = HabitEntity(name: "Hábito sin racha")
        
        let repository = MockHabitRepository(initialHabits: [habit1, habit2])
        let getHabitsUseCase = GetHabitsUseCase(repository: repository)
        let calculateStatsUseCase = CalculateHabitStatsUseCase(calendar: calendar)
        
        let viewModel = StatsViewModel(
            getHabitsUseCase: getHabitsUseCase,
            calculateHabitStatsUseCase: calculateStatsUseCase
        )
        
        await viewModel.loadStats(referenceDate: today)
        
        #expect(viewModel.hasHabits == true)
        #expect(viewModel.stats.count == 2)
        #expect(viewModel.streaksForChart.count == 1)
        #expect(viewModel.streaksForChart.first?.habitName == "Hábito con racha")
        #expect(viewModel.streaksForChart.first?.streak == 1)
    }
}
