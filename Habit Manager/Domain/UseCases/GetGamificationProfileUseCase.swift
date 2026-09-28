import Foundation

public struct GamificationOverview: Sendable, Equatable {
    public let profile: UserGamificationProfile
    public let achievements: [AchievementEntity]
    
    public init(profile: UserGamificationProfile, achievements: [AchievementEntity]) {
        self.profile = profile
        self.achievements = achievements
    }
}

public protocol GetGamificationProfileUseCaseProtocol: Sendable {
    func execute(habits: [HabitEntity], referenceDate: Date) async throws -> GamificationOverview
}

public struct GetGamificationProfileUseCase: GetGamificationProfileUseCaseProtocol {
    private let evaluateAchievementsUseCase: EvaluateAchievementsUseCaseProtocol
    private let gamificationRepository: GamificationRepositoryProtocol
    
    public init(
        evaluateAchievementsUseCase: EvaluateAchievementsUseCaseProtocol,
        gamificationRepository: GamificationRepositoryProtocol
    ) {
        self.evaluateAchievementsUseCase = evaluateAchievementsUseCase
        self.gamificationRepository = gamificationRepository
    }
    
    public func execute(
        habits: [HabitEntity],
        referenceDate: Date = .now
    ) async throws -> GamificationOverview {
        let result = try await evaluateAchievementsUseCase.execute(
            habits: habits,
            referenceDate: referenceDate
        )
        
        let totalXP = try await gamificationRepository.getTotalXP()
        let unlockedCount = result.allAchievements.filter { $0.isUnlocked }.count
        let totalCount = result.allAchievements.count
        
        let profile = UserGamificationProfile(
            totalXP: totalXP,
            unlockedAchievementsCount: unlockedCount,
            totalAchievementsCount: totalCount
        )
        
        return GamificationOverview(
            profile: profile,
            achievements: result.allAchievements
        )
    }
}
