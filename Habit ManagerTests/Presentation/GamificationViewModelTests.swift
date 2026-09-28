import Testing
import Foundation
@testable import Habit_Manager

@MainActor
struct GamificationViewModelTests {
    
    @Test func loadDataPopulatesProfileAndAchievements() async throws {
        let habitRepo = MockHabitRepository()
        let gamificationRepo = MockGamificationRepository(initialXP: 250)
        let evalUseCase = EvaluateAchievementsUseCase(repository: gamificationRepo)
        let getProfileUseCase = GetGamificationProfileUseCase(
            evaluateAchievementsUseCase: evalUseCase,
            gamificationRepository: gamificationRepo
        )
        let getHabitsUseCase = GetHabitsUseCase(repository: habitRepo)
        
        let viewModel = GamificationViewModel(
            getGamificationProfileUseCase: getProfileUseCase,
            getHabitsUseCase: getHabitsUseCase
        )
        
        await viewModel.loadData()
        
        #expect(viewModel.profile != nil)
        #expect(viewModel.profile?.level == 2)
        #expect(viewModel.profile?.levelTitle == "Aprendiz")
        #expect(!viewModel.allAchievements.isEmpty)
        #expect(viewModel.totalCount == AchievementType.allCases.count)
    }
    
    @Test func categoryFiltering() async throws {
        let habitRepo = MockHabitRepository()
        let gamificationRepo = MockGamificationRepository()
        let evalUseCase = EvaluateAchievementsUseCase(repository: gamificationRepo)
        let getProfileUseCase = GetGamificationProfileUseCase(
            evaluateAchievementsUseCase: evalUseCase,
            gamificationRepository: gamificationRepo
        )
        let getHabitsUseCase = GetHabitsUseCase(repository: habitRepo)
        
        let viewModel = GamificationViewModel(
            getGamificationProfileUseCase: getProfileUseCase,
            getHabitsUseCase: getHabitsUseCase
        )
        
        await viewModel.loadData()
        
        viewModel.selectedCategory = .streaks
        #expect(viewModel.filteredAchievements.allSatisfy { $0.category == .streaks })
        #expect(!viewModel.filteredAchievements.isEmpty)
        
        viewModel.selectedCategory = nil
        #expect(viewModel.filteredAchievements.count == viewModel.allAchievements.count)
    }
}
