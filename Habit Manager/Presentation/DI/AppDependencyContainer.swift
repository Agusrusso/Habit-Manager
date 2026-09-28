import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
public final class AppDependencyContainer {
    public let repository: HabitRepositoryProtocol
    public let notificationService: NotificationServiceProtocol
    public let gamificationRepository: GamificationRepositoryProtocol
    
    public let getHabitsUseCase: GetHabitsUseCaseProtocol
    public let getTodaysHabitsUseCase: GetTodaysHabitsUseCaseProtocol
    public let toggleHabitCompletionUseCase: ToggleHabitCompletionUseCaseProtocol
    public let calculateHabitStatsUseCase: CalculateHabitStatsUseCaseProtocol
    public let saveHabitUseCase: SaveHabitUseCaseProtocol
    public let deleteHabitUseCase: DeleteHabitUseCaseProtocol
    
    public let evaluateAchievementsUseCase: EvaluateAchievementsUseCaseProtocol
    public let getGamificationProfileUseCase: GetGamificationProfileUseCaseProtocol
    public let awardHabitCompletionXPUseCase: AwardHabitCompletionXPUseCaseProtocol
    
    public init(
        repository: HabitRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        gamificationRepository: GamificationRepositoryProtocol = UserDefaultsGamificationRepository()
    ) {
        self.repository = repository
        self.notificationService = notificationService
        self.gamificationRepository = gamificationRepository
        
        self.getHabitsUseCase = GetHabitsUseCase(repository: repository)
        self.getTodaysHabitsUseCase = GetTodaysHabitsUseCase(repository: repository)
        self.toggleHabitCompletionUseCase = ToggleHabitCompletionUseCase(repository: repository)
        self.calculateHabitStatsUseCase = CalculateHabitStatsUseCase()
        self.saveHabitUseCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        self.deleteHabitUseCase = DeleteHabitUseCase(repository: repository, notificationService: notificationService)
        
        let evalUseCase = EvaluateAchievementsUseCase(repository: gamificationRepository)
        self.evaluateAchievementsUseCase = evalUseCase
        self.getGamificationProfileUseCase = GetGamificationProfileUseCase(
            evaluateAchievementsUseCase: evalUseCase,
            gamificationRepository: gamificationRepository
        )
        self.awardHabitCompletionXPUseCase = AwardHabitCompletionXPUseCase(
            gamificationRepository: gamificationRepository
        )
    }
    
    public convenience init(modelContainer: ModelContainer) {
        let repository = SwiftDataHabitRepository(modelContainer: modelContainer)
        let notificationService = AppNotificationService.shared
        let gamificationRepository = UserDefaultsGamificationRepository()
        self.init(
            repository: repository,
            notificationService: notificationService,
            gamificationRepository: gamificationRepository
        )
    }
    
    public func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(
            getTodaysHabitsUseCase: getTodaysHabitsUseCase,
            toggleHabitCompletionUseCase: toggleHabitCompletionUseCase,
            awardHabitCompletionXPUseCase: awardHabitCompletionXPUseCase,
            evaluateAchievementsUseCase: evaluateAchievementsUseCase
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
    
    public func makeGamificationViewModel() -> GamificationViewModel {
        GamificationViewModel(
            getGamificationProfileUseCase: getGamificationProfileUseCase,
            getHabitsUseCase: getHabitsUseCase
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
