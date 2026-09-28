import Foundation

public struct HabitWidgetItem: Codable, Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let habitDescription: String
    public let isCompleted: Bool
    public let currentStreak: Int
    public let progress: Int
    public let goal: Int
    public let unit: String
    public let isQuantitative: Bool
    
    public init(
        id: UUID,
        name: String,
        habitDescription: String = "",
        isCompleted: Bool,
        currentStreak: Int = 0,
        progress: Int = 0,
        goal: Int = 1,
        unit: String = "",
        isQuantitative: Bool = false
    ) {
        self.id = id
        self.name = name
        self.habitDescription = habitDescription
        self.isCompleted = isCompleted
        self.currentStreak = currentStreak
        self.progress = progress
        self.goal = goal
        self.unit = unit
        self.isQuantitative = isQuantitative
    }
}

public struct HabitWidgetSnapshot: Codable, Sendable, Equatable {
    public let habits: [HabitWidgetItem]
    public let totalCount: Int
    public let completedCount: Int
    public let completionPercentage: Double
    public let highestStreak: Int
    public let lastUpdated: Date
    
    public init(
        habits: [HabitWidgetItem] = [],
        highestStreak: Int = 0,
        lastUpdated: Date = .now
    ) {
        self.habits = habits
        self.totalCount = habits.count
        self.completedCount = habits.filter(\.isCompleted).count
        self.completionPercentage = habits.isEmpty ? 0 : (Double(completedCount) / Double(habits.count)) * 100
        self.highestStreak = highestStreak
        self.lastUpdated = lastUpdated
    }
    
    public static var empty: HabitWidgetSnapshot {
        HabitWidgetSnapshot(habits: [], highestStreak: 0, lastUpdated: .now)
    }
    
    public static var previewSample: HabitWidgetSnapshot {
        HabitWidgetSnapshot(
            habits: [
                HabitWidgetItem(
                    id: UUID(),
                    name: "Beber 2L de agua",
                    isCompleted: true,
                    currentStreak: 5,
                    progress: 8,
                    goal: 8,
                    unit: "vasos",
                    isQuantitative: true
                ),
                HabitWidgetItem(
                    id: UUID(),
                    name: "Leer 30 minutos",
                    isCompleted: false,
                    currentStreak: 3,
                    progress: 0,
                    goal: 1,
                    unit: "",
                    isQuantitative: false
                ),
                HabitWidgetItem(
                    id: UUID(),
                    name: "Caminar 10.000 pasos",
                    isCompleted: false,
                    currentStreak: 7,
                    progress: 6500,
                    goal: 10000,
                    unit: "pasos",
                    isQuantitative: true
                )
            ],
            highestStreak: 7,
            lastUpdated: .now
        )
    }
}
