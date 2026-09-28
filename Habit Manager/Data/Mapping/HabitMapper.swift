import Foundation
import SwiftData

extension Habit {
    public func toEntity() -> HabitEntity {
        HabitEntity(
            id: self.id,
            name: self.name,
            description: self.habitDescription,
            frequency: self.frequency,
            creationDate: self.creationDate,
            reminderEnabled: self.reminderEnabled,
            reminderTime: self.reminderTime,
            type: self.type,
            goal: self.goal,
            unit: self.unit,
            logs: (self.logs ?? []).map { $0.toEntity() }
        )
    }
    
    public convenience init(from entity: HabitEntity) {
        self.init(
            id: entity.id,
            name: entity.name,
            description: entity.habitDescription,
            frequency: entity.frequency,
            creationDate: entity.creationDate,
            reminderEnabled: entity.reminderEnabled,
            reminderTime: entity.reminderTime,
            type: entity.type,
            goal: entity.goal,
            unit: entity.unit
        )
        self.logs = entity.logs.map { HabitLog(date: $0.date, progress: $0.progress) }
    }
    
    public func update(from entity: HabitEntity) {
        self.name = entity.name
        self.habitDescription = entity.habitDescription
        self.frequency = entity.frequency
        self.reminderEnabled = entity.reminderEnabled
        self.reminderTime = entity.reminderTime
        self.type = entity.type
        self.goal = entity.goal
        self.unit = entity.unit
    }
}

extension HabitLog {
    public func toEntity() -> HabitLogEntity {
        HabitLogEntity(
            date: self.date,
            progress: self.progress
        )
    }
}
