import Foundation
import Observation

@MainActor
@Observable
public final class TodayViewModel {
    private let getTodaysHabitsUseCase: GetTodaysHabitsUseCaseProtocol
    private let toggleHabitCompletionUseCase: ToggleHabitCompletionUseCaseProtocol
    private let awardHabitCompletionXPUseCase: AwardHabitCompletionXPUseCaseProtocol?
    private let evaluateAchievementsUseCase: EvaluateAchievementsUseCaseProtocol?
    private let calendar: Calendar
    
    public var habits: [HabitEntity] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var latestUnlockedAchievement: AchievementEntity? = nil
    public var showAchievementToast: Bool = false
    
    public init(
        getTodaysHabitsUseCase: GetTodaysHabitsUseCaseProtocol,
        toggleHabitCompletionUseCase: ToggleHabitCompletionUseCaseProtocol,
        awardHabitCompletionXPUseCase: AwardHabitCompletionXPUseCaseProtocol? = nil,
        evaluateAchievementsUseCase: EvaluateAchievementsUseCaseProtocol? = nil,
        calendar: Calendar = .current
    ) {
        self.getTodaysHabitsUseCase = getTodaysHabitsUseCase
        self.toggleHabitCompletionUseCase = toggleHabitCompletionUseCase
        self.awardHabitCompletionXPUseCase = awardHabitCompletionXPUseCase
        self.evaluateAchievementsUseCase = evaluateAchievementsUseCase
        self.calendar = calendar
    }
    
    public func loadHabits(for date: Date = .now) async {
        isLoading = true
        errorMessage = nil
        do {
            habits = try await getTodaysHabitsUseCase.execute(for: date)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func toggleCompletion(for habit: HabitEntity, on date: Date = .now) async {
        do {
            let wasCompleted = habit.isCompleted(on: date, calendar: calendar)
            let updatedHabit = try await toggleHabitCompletionUseCase.execute(habitId: habit.id, on: date)
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[index] = updatedHabit
            }
            
            let isNowCompleted = updatedHabit.isCompleted(on: date, calendar: calendar)
            if !wasCompleted && isNowCompleted {
                await handleHabitCompleted(updatedHabit, on: date)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func setProgress(for habit: HabitEntity, progress: Int, on date: Date = .now) async {
        do {
            let wasCompleted = habit.isCompleted(on: date, calendar: calendar)
            let updatedHabit = try await toggleHabitCompletionUseCase.setProgress(habitId: habit.id, on: date, progress: progress)
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[index] = updatedHabit
            }
            
            let isNowCompleted = updatedHabit.isCompleted(on: date, calendar: calendar)
            if !wasCompleted && isNowCompleted {
                await handleHabitCompleted(updatedHabit, on: date)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func dismissAchievementToast() {
        showAchievementToast = false
        latestUnlockedAchievement = nil
    }
    
    private func handleHabitCompleted(_ habit: HabitEntity, on date: Date) async {
        _ = try? await awardHabitCompletionXPUseCase?.execute(
            isCompleted: true,
            isQuantitative: habit.type == .quantitative
        )
        
        if let evaluateAchievementsUseCase {
            let result = try? await evaluateAchievementsUseCase.execute(
                habits: habits,
                referenceDate: date
            )
            if let newlyUnlocked = result?.newlyUnlocked.first {
                self.latestUnlockedAchievement = newlyUnlocked
                self.showAchievementToast = true
            }
        }
    }
}
