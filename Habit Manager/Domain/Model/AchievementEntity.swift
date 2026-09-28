import Foundation

public struct AchievementEntity: Identifiable, Sendable, Equatable {
    public let type: AchievementType
    public let currentProgress: Int
    public let unlockedAt: Date?
    
    public var id: String { type.rawValue }
    public var title: String { type.title }
    public var description: String { type.description }
    public var iconName: String { type.iconName }
    public var category: AchievementCategory { type.category }
    public var targetProgress: Int { type.targetProgress }
    public var xpReward: Int { type.xpReward }
    
    public var isUnlocked: Bool {
        unlockedAt != nil
    }
    
    public var progressPercentage: Double {
        guard targetProgress > 0 else { return 0 }
        let clamped = min(max(currentProgress, 0), targetProgress)
        return Double(clamped) / Double(targetProgress)
    }
    
    public init(
        type: AchievementType,
        currentProgress: Int,
        unlockedAt: Date? = nil
    ) {
        self.type = type
        self.currentProgress = currentProgress
        self.unlockedAt = unlockedAt
    }
}
