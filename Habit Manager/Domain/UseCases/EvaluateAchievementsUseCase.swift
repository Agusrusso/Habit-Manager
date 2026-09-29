import Foundation

public struct AchievementEvaluationResult: Sendable, Equatable {
    public let newlyUnlocked: [AchievementEntity]
    public let allAchievements: [AchievementEntity]
    public let awardedXP: Int
    
    public init(
        newlyUnlocked: [AchievementEntity],
        allAchievements: [AchievementEntity],
        awardedXP: Int
    ) {
        self.newlyUnlocked = newlyUnlocked
        self.allAchievements = allAchievements
        self.awardedXP = awardedXP
    }
}

public protocol EvaluateAchievementsUseCaseProtocol: Sendable {
    func execute(
        habits: [HabitEntity],
        referenceDate: Date
    ) async throws -> AchievementEvaluationResult
}

public struct EvaluateAchievementsUseCase: EvaluateAchievementsUseCaseProtocol {
    private let repository: GamificationRepositoryProtocol
    private let calendar: Calendar
    
    public init(
        repository: GamificationRepositoryProtocol,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func execute(
        habits: [HabitEntity],
        referenceDate: Date = .now
    ) async throws -> AchievementEvaluationResult {
        let unlockedDict = try await repository.getUnlockedAchievements()
        
        let totalHabitsCount = habits.count
        let maxStreak = habits.map { $0.currentStreak(at: referenceDate, calendar: calendar) }.max() ?? 0
        
        var totalCompletedLogs = 0
        var quantitativeCompletions = 0
        
        for habit in habits {
            for log in habit.logs {
                if log.progress >= habit.goal {
                    totalCompletedLogs += 1
                    if habit.type == .quantitative {
                        quantitativeCompletions += 1
                    }
                }
            }
        }
        
        let scheduledToday = habits.filter { $0.isScheduled(on: referenceDate, calendar: calendar) }
        let isPerfectDayToday = scheduledToday.count >= 3 && scheduledToday.allSatisfy { $0.isCompleted(on: referenceDate, calendar: calendar) }
        
        var allEntities: [AchievementEntity] = []
        var newlyUnlocked: [AchievementEntity] = []
        var totalAwardedXP = 0
        
        for type in AchievementType.allCases {
            let currentProgress: Int
            
            switch type {
            case .firstHabitCreated:
                currentProgress = totalHabitsCount >= 1 ? 1 : 0
            case .firstHabitCompleted:
                currentProgress = totalCompletedLogs >= 1 ? 1 : 0
            case .streak3Days, .streak7Days, .streak14Days, .streak21Days, .streak30Days, .streak100Days:
                currentProgress = maxStreak
            case .perfectDay:
                let previouslyUnlocked = unlockedDict[type.rawValue] != nil
                currentProgress = (isPerfectDayToday || previouslyUnlocked) ? 1 : 0
            case .tenCompletions, .fiftyCompletions, .centurion:
                currentProgress = totalCompletedLogs
            case .quantitativeFirstGoal, .quantitativeMaster:
                currentProgress = quantitativeCompletions
            }
            
            let previouslyUnlockedAt = unlockedDict[type.rawValue]
            let shouldUnlock = previouslyUnlockedAt != nil || currentProgress >= type.targetProgress
            
            if previouslyUnlockedAt == nil && shouldUnlock {
                let unlockDate = referenceDate
                try await repository.saveUnlockedAchievement(id: type.rawValue, unlockedAt: unlockDate)
                _ = try await repository.addXP(amount: type.xpReward)
                totalAwardedXP += type.xpReward
                
                let entity = AchievementEntity(
                    type: type,
                    currentProgress: currentProgress,
                    unlockedAt: unlockDate
                )
                newlyUnlocked.append(entity)
                allEntities.append(entity)
            } else {
                let entity = AchievementEntity(
                    type: type,
                    currentProgress: currentProgress,
                    unlockedAt: previouslyUnlockedAt
                )
                allEntities.append(entity)
            }
        }
        
        return AchievementEvaluationResult(
            newlyUnlocked: newlyUnlocked,
            allAchievements: allEntities,
            awardedXP: totalAwardedXP
        )
    }
}
