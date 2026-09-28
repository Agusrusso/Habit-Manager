import Foundation
@testable import Habit_Manager

public final class MockGamificationRepository: GamificationRepositoryProtocol, @unchecked Sendable {
    private var unlocked: [String: Date] = [:]
    private var totalXP: Int = 0
    private let lock = NSLock()
    
    public init(
        initialUnlocked: [String: Date] = [:],
        initialXP: Int = 0
    ) {
        self.unlocked = initialUnlocked
        self.totalXP = initialXP
    }
    
    public func getUnlockedAchievements() async throws -> [String: Date] {
        lock.lock()
        defer { lock.unlock() }
        return unlocked
    }
    
    public func saveUnlockedAchievement(id: String, unlockedAt: Date) async throws {
        lock.lock()
        defer { lock.unlock() }
        unlocked[id] = unlockedAt
    }
    
    public func getTotalXP() async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        return totalXP
    }
    
    public func addXP(amount: Int) async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        totalXP += amount
        return totalXP
    }
}
