import Foundation

public final class UserDefaultsGamificationRepository: GamificationRepositoryProtocol, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let unlockedKey = "gamification.unlocked_achievements"
    private let xpKey = "gamification.total_xp"
    private let lock = NSLock()
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func getUnlockedAchievements() async throws -> [String: Date] {
        lock.lock()
        defer { lock.unlock() }
        
        guard let dict = userDefaults.dictionary(forKey: unlockedKey) as? [String: Double] else {
            return [:]
        }
        
        return dict.reduce(into: [String: Date]()) { result, pair in
            result[pair.key] = Date(timeIntervalSince1970: pair.value)
        }
    }
    
    public func saveUnlockedAchievement(id: String, unlockedAt: Date) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        var dict = (userDefaults.dictionary(forKey: unlockedKey) as? [String: Double]) ?? [:]
        dict[id] = unlockedAt.timeIntervalSince1970
        userDefaults.set(dict, forKey: unlockedKey)
    }
    
    public func getTotalXP() async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        return userDefaults.integer(forKey: xpKey)
    }
    
    public func addXP(amount: Int) async throws -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        let current = userDefaults.integer(forKey: xpKey)
        let updated = max(current + amount, 0)
        userDefaults.set(updated, forKey: xpKey)
        return updated
    }
}
