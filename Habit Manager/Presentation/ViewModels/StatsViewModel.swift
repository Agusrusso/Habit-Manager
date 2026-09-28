import Foundation
import Observation

@MainActor
@Observable
public final class StatsViewModel {
    private let getHabitsUseCase: GetHabitsUseCaseProtocol
    private let calculateHabitStatsUseCase: CalculateHabitStatsUseCaseProtocol
    
    public var stats: [HabitStatsSummary] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var streaksForChart: [HabitStatsSummary] {
        stats.filter { $0.streak > 0 }
    }
    
    public var hasHabits: Bool {
        !stats.isEmpty
    }
    
    public var hasStreaks: Bool {
        !streaksForChart.isEmpty
    }
    
    public init(
        getHabitsUseCase: GetHabitsUseCaseProtocol,
        calculateHabitStatsUseCase: CalculateHabitStatsUseCaseProtocol
    ) {
        self.getHabitsUseCase = getHabitsUseCase
        self.calculateHabitStatsUseCase = calculateHabitStatsUseCase
    }
    
    public func loadStats(referenceDate: Date = .now) async {
        isLoading = true
        errorMessage = nil
        do {
            let habits = try await getHabitsUseCase.execute()
            stats = calculateHabitStatsUseCase.execute(for: habits, referenceDate: referenceDate)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
