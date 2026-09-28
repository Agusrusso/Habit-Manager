import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
public final class AppDependencyContainer {
    public let repository: HabitRepositoryProtocol
    public let notificationService: NotificationServiceProtocol
    
    public let getHabitsUseCase: GetHabitsUseCaseProtocol
    public let getTodaysHabitsUseCase: GetTodaysHabitsUseCaseProtocol
    public let toggleHabitCompletionUseCase: ToggleHabitCompletionUseCaseProtocol
    public let calculateHabitStatsUseCase: CalculateHabitStatsUseCaseProtocol
    public let saveHabitUseCase: SaveHabitUseCaseProtocol
    public let deleteHabitUseCase: DeleteHabitUseCaseProtocol
    
    public init(
        repository: HabitRepositoryProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.repository = repository
        self.notificationService = notificationService
        
        self.getHabitsUseCase = GetHabitsUseCase(repository: repository)
        self.getTodaysHabitsUseCase = GetTodaysHabitsUseCase(repository: repository)
        self.toggleHabitCompletionUseCase = ToggleHabitCompletionUseCase(repository: repository)
        self.calculateHabitStatsUseCase = CalculateHabitStatsUseCase()
        self.saveHabitUseCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        self.deleteHabitUseCase = DeleteHabitUseCase(repository: repository, notificationService: notificationService)
    }
    
    public convenience init(modelContainer: ModelContainer) {
        let repository = SwiftDataHabitRepository(modelContainer: modelContainer)
        let notificationService = AppNotificationService.shared
        self.init(repository: repository, notificationService: notificationService)
    }
    
    public func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(
            getTodaysHabitsUseCase: getTodaysHabitsUseCase,
            toggleHabitCompletionUseCase: toggleHabitCompletionUseCase
        )
    }
    
    public func makeHabitListViewModel() -> HabitListViewModel {
        HabitListViewModel(
            getHabitsUseCase: getHabitsUseCase,
            deleteHabitUseCase: deleteHabitUseCase
        )
    }
    
    public func makeAddEditHabitViewModel(habitToEdit: HabitEntity? = nil) -> AddEditHabitViewModel {
        AddEditHabitViewModel(
            habitToEdit: habitToEdit,
            saveHabitUseCase: saveHabitUseCase
        )
    }
    
    public func makeStatsViewModel() -> StatsViewModel {
        StatsViewModel(
            getHabitsUseCase: getHabitsUseCase,
            calculateHabitStatsUseCase: calculateHabitStatsUseCase
        )
    }
}

private struct DependencyContainerKey: EnvironmentKey {
    @MainActor static let defaultValue: AppDependencyContainer? = nil
}

extension EnvironmentValues {
    public var dependencyContainer: AppDependencyContainer? {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
