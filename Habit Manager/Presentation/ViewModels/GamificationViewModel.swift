import Foundation
import Observation

@Observable
@MainActor
public final class GamificationViewModel {
    private let getGamificationProfileUseCase: GetGamificationProfileUseCaseProtocol
    private let getHabitsUseCase: GetHabitsUseCaseProtocol
    
    public var profile: UserGamificationProfile?
    public var allAchievements: [AchievementEntity] = []
    public var selectedCategory: AchievementCategory?
    public var selectedAchievementForDetail: AchievementEntity?
    public var isLoading: Bool = false
    public var errorMessage: String?
    
    public var filteredAchievements: [AchievementEntity] {
        guard let category = selectedCategory else {
            return allAchievements
        }
        return allAchievements.filter { $0.category == category }
    }
    
    public var unlockedCount: Int {
        allAchievements.filter { $0.isUnlocked }.count
    }
    
    public var totalCount: Int {
        allAchievements.count
    }
    
    public init(
        getGamificationProfileUseCase: GetGamificationProfileUseCaseProtocol,
        getHabitsUseCase: GetHabitsUseCaseProtocol
    ) {
        self.getGamificationProfileUseCase = getGamificationProfileUseCase
        self.getHabitsUseCase = getHabitsUseCase
    }
    
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let habits = try await getHabitsUseCase.execute()
            let overview = try await getGamificationProfileUseCase.execute(habits: habits, referenceDate: .now)
            self.profile = overview.profile
            self.allAchievements = overview.achievements
        } catch {
            self.errorMessage = "No se pudieron cargar los logros: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
