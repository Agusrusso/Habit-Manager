import Foundation

extension UserDefaults: @unchecked @retroactive Sendable {}

public actor UserDefaultsGamificationRepository: GamificationRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let unlockedKey = "gamification.unlocked_achievements"
    private let xpKey = "gamification.total_xp"
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func getUnlockedAchievements() async throws -> [String: Date] {
        guard let dict = userDefaults.dictionary(forKey: unlockedKey) as? [String: Double] else {
            return [:]
        }
        
        return dict.reduce(into: [String: Date]()) { result, pair in
            result[pair.key] = Date(timeIntervalSince1970: pair.value)
        }
    }
    
    public func saveUnlockedAchievement(id: String, unlockedAt: Date) async throws {
        var dict = (userDefaults.dictionary(forKey: unlockedKey) as? [String: Double]) ?? [:]
        dict[id] = unlockedAt.timeIntervalSince1970
        userDefaults.set(dict, forKey: unlockedKey)
    }
    
    public func getTotalXP() async throws -> Int {
        return userDefaults.integer(forKey: xpKey)
    }
    
    public func addXP(amount: Int) async throws -> Int {
        let current = userDefaults.integer(forKey: xpKey)
        let updated = max(current + amount, 0)
        userDefaults.set(updated, forKey: xpKey)
        return updated
    }
}
