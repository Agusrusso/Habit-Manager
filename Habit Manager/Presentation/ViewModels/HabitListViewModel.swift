import Foundation
import Observation

@MainActor
@Observable
public final class HabitListViewModel {
    private let getHabitsUseCase: GetHabitsUseCaseProtocol
    private let deleteHabitUseCase: DeleteHabitUseCaseProtocol
    
    public var habits: [HabitEntity] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var selectedHabitForEdit: HabitEntity? = nil
    public var isShowingAddSheet: Bool = false
    
    public init(
        getHabitsUseCase: GetHabitsUseCaseProtocol,
        deleteHabitUseCase: DeleteHabitUseCaseProtocol
    ) {
        self.getHabitsUseCase = getHabitsUseCase
        self.deleteHabitUseCase = deleteHabitUseCase
    }
    
    public func loadHabits() async {
        isLoading = true
        errorMessage = nil
        do {
            habits = try await getHabitsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func deleteHabit(_ habit: HabitEntity) async {
        do {
            try await deleteHabitUseCase.execute(habitId: habit.id)
            habits.removeAll { $0.id == habit.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func deleteHabits(at offsets: IndexSet) async {
        let habitsToDelete = offsets.map { habits[$0] }
        for habit in habitsToDelete {
            await deleteHabit(habit)
        }
    }
}
