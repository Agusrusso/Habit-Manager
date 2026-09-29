import Foundation

public struct UserGamificationProfile: Sendable, Equatable {
    public let totalXP: Int
    public let level: Int
    public let levelTitle: String
    public let xpForCurrentLevel: Int
    public let xpForNextLevel: Int
    public let progressInLevel: Double
    public let unlockedAchievementsCount: Int
    public let totalAchievementsCount: Int
    
    public init(
        totalXP: Int,
        unlockedAchievementsCount: Int,
        totalAchievementsCount: Int
    ) {
        self.totalXP = max(totalXP, 0)
        self.unlockedAchievementsCount = unlockedAchievementsCount
        self.totalAchievementsCount = totalAchievementsCount
        
        let levelInfo = UserGamificationProfile.calculateLevel(from: self.totalXP)
        self.level = levelInfo.level
        self.levelTitle = levelInfo.title
        self.xpForCurrentLevel = levelInfo.currentBaseXP
        self.xpForNextLevel = levelInfo.nextThresholdXP
        self.progressInLevel = levelInfo.progress
    }
    
    private static func calculateLevel(from xp: Int) -> (level: Int, title: String, currentBaseXP: Int, nextThresholdXP: Int, progress: Double) {
        let tiers: [(level: Int, title: String, threshold: Int)] = [
            (1, "Novato", 0),
            (2, "Aprendiz", 100),
            (3, "Constante", 300),
            (4, "Disciplinado", 650),
            (5, "Maestro del Hábito", 1200),
            (6, "Gran Maestro", 2000),
            (7, "Leyenda", 3200)
        ]
        
        for i in (0..<tiers.count).reversed() {
            let tier = tiers[i]
            if xp >= tier.threshold {
                let currentBase = tier.threshold
                if i < tiers.count - 1 {
                    let nextThreshold = tiers[i + 1].threshold
                    let range = nextThreshold - currentBase
                    let earnedInRange = xp - currentBase
                    let progress = min(max(Double(earnedInRange) / Double(range), 0.0), 1.0)
                    return (tier.level, tier.title, currentBase, nextThreshold, progress)
                } else {
                    return (tier.level, tier.title, currentBase, currentBase + 2000, 1.0)
                }
            }
        }
        
        return (1, "Novato", 0, 100, Double(xp) / 100.0)
    }
}
