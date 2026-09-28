import Foundation
import Observation

@MainActor
@Observable
public final class TodayViewModel {
    private let getTodaysHabitsUseCase: GetTodaysHabitsUseCaseProtocol
    private let toggleHabitCompletionUseCase: ToggleHabitCompletionUseCaseProtocol
    private let calendar: Calendar
    
    public var habits: [HabitEntity] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public init(
        getTodaysHabitsUseCase: GetTodaysHabitsUseCaseProtocol,
        toggleHabitCompletionUseCase: ToggleHabitCompletionUseCaseProtocol,
        calendar: Calendar = .current
    ) {
        self.getTodaysHabitsUseCase = getTodaysHabitsUseCase
        self.toggleHabitCompletionUseCase = toggleHabitCompletionUseCase
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
            let updatedHabit = try await toggleHabitCompletionUseCase.execute(habitId: habit.id, on: date)
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[index] = updatedHabit
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func setProgress(for habit: HabitEntity, progress: Int, on date: Date = .now) async {
        do {
            let updatedHabit = try await toggleHabitCompletionUseCase.setProgress(habitId: habit.id, on: date, progress: progress)
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[index] = updatedHabit
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
