import Foundation

public protocol GamificationRepositoryProtocol: Sendable {
    func getUnlockedAchievements() async throws -> [String: Date]
    func saveUnlockedAchievement(id: String, unlockedAt: Date) async throws
    func getTotalXP() async throws -> Int
    func addXP(amount: Int) async throws -> Int
}
