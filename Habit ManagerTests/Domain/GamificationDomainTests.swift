import Testing
import Foundation
@testable import Habit_Manager

struct GamificationDomainTests {
    
    @Test func userProfileLevelsAndProgress() {
        let profile1 = UserGamificationProfile(totalXP: 50, unlockedAchievementsCount: 2, totalAchievementsCount: 14)
        #expect(profile1.level == 1)
        #expect(profile1.levelTitle == "Novato")
        #expect(profile1.progressInLevel == 0.5)
        
        let profile2 = UserGamificationProfile(totalXP: 200, unlockedAchievementsCount: 5, totalAchievementsCount: 14)
        #expect(profile2.level == 2)
        #expect(profile2.levelTitle == "Aprendiz")
        #expect(profile2.progressInLevel == 0.5)
        
        let profile3 = UserGamificationProfile(totalXP: 300, unlockedAchievementsCount: 6, totalAchievementsCount: 14)
        #expect(profile3.level == 3)
        #expect(profile3.levelTitle == "Constante")
        #expect(profile3.progressInLevel == 0.0)
        
        let profile7 = UserGamificationProfile(totalXP: 5000, unlockedAchievementsCount: 14, totalAchievementsCount: 14)
        #expect(profile7.level == 7)
        #expect(profile7.levelTitle == "Leyenda")
        #expect(profile7.progressInLevel == 1.0)
    }
    
    @Test func evaluateFirstHabitCreatedAndCompleted() async throws {
        let repo = MockGamificationRepository()
        let useCase = EvaluateAchievementsUseCase(repository: repo)
        let calendar = Calendar.current
        let today = Date()
        
        let resultEmpty = try await useCase.execute(habits: [], referenceDate: today)
        #expect(resultEmpty.newlyUnlocked.isEmpty)
        #expect(resultEmpty.awardedXP == 0)
        
        let habit1 = HabitEntity(
            id: UUID(),
            name: "Hacer ejercicio",
            frequency: .daily,
            type: .simple
        )
        
        let result1 = try await useCase.execute(habits: [habit1], referenceDate: today)
        #expect(result1.newlyUnlocked.contains(where: { $0.type == .firstHabitCreated }))
        #expect(!result1.newlyUnlocked.contains(where: { $0.type == .firstHabitCompleted }))
        #expect(result1.awardedXP == AchievementType.firstHabitCreated.xpReward)
        
        let log = HabitLogEntity(id: UUID(), date: today, progress: 1)
        let habitWithLog = HabitEntity(
            id: habit1.id,
            name: habit1.name,
            frequency: .daily,
            type: .simple,
            logs: [log]
        )
        
        let result2 = try await useCase.execute(habits: [habitWithLog], referenceDate: today)
        #expect(result2.newlyUnlocked.contains(where: { $0.type == .firstHabitCompleted }))
        #expect(!result2.newlyUnlocked.contains(where: { $0.type == .firstHabitCreated }))
        #expect(result2.awardedXP == AchievementType.firstHabitCompleted.xpReward)
        
        let totalXP = try await repo.getTotalXP()
        #expect(totalXP == AchievementType.firstHabitCreated.xpReward + AchievementType.firstHabitCompleted.xpReward)
    }
    
    @Test func evaluateStreakAchievements() async throws {
        let repo = MockGamificationRepository()
        let useCase = EvaluateAchievementsUseCase(repository: repo)
        let calendar = Calendar.current
        let today = Date()
        
        var logs: [HabitLogEntity] = []
        for daysAgo in 0..<7 {
            let logDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            logs.append(HabitLogEntity(id: UUID(), date: logDate, progress: 1))
        }
        
        let habit = HabitEntity(
            id: UUID(),
            name: "Meditar",
            frequency: .daily,
            type: .simple,
            logs: logs
        )
        
        let result = try await useCase.execute(habits: [habit], referenceDate: today)
        
        #expect(result.newlyUnlocked.contains(where: { $0.type == .streak3Days }))
        #expect(result.newlyUnlocked.contains(where: { $0.type == .streak7Days }))
        #expect(!result.newlyUnlocked.contains(where: { $0.type == .streak14Days }))
        
        let streak3 = result.allAchievements.first(where: { $0.type == .streak3Days })!
        #expect(streak3.isUnlocked)
        #expect(streak3.currentProgress >= 7)
    }
    
    @Test func evaluatePerfectDay() async throws {
        let repo = MockGamificationRepository()
        let useCase = EvaluateAchievementsUseCase(repository: repo)
        let today = Date()
        
        let h1 = HabitEntity(id: UUID(), name: "H1", frequency: .daily, type: .simple, logs: [HabitLogEntity(id: UUID(), date: today, progress: 1)])
        let h2 = HabitEntity(id: UUID(), name: "H2", frequency: .daily, type: .simple, logs: [HabitLogEntity(id: UUID(), date: today, progress: 1)])
        let h3 = HabitEntity(id: UUID(), name: "H3", frequency: .daily, type: .simple, logs: [HabitLogEntity(id: UUID(), date: today, progress: 1)])
        
        let result = try await useCase.execute(habits: [h1, h2, h3], referenceDate: today)
        #expect(result.newlyUnlocked.contains(where: { $0.type == .perfectDay }))
    }
    
    @Test func awardHabitCompletionXP() async throws {
        let repo = MockGamificationRepository()
        let useCase = AwardHabitCompletionXPUseCase(gamificationRepository: repo)
        
        let xpSimple = try await useCase.execute(isCompleted: true, isQuantitative: false)
        #expect(xpSimple == 10)
        
        let xpQuant = try await useCase.execute(isCompleted: true, isQuantitative: true)
        #expect(xpQuant == 25)
        
        let xpNone = try await useCase.execute(isCompleted: false, isQuantitative: false)
        #expect(xpNone == 0)
    }
}
