import Foundation
import SwiftUI
import SwiftData

@Model
final class Habit {
    var id: UUID = UUID()
    
    var name: String = ""
    var habitDescription: String = ""
    var creationDate: Date = Date()
    var reminderEnabled: Bool = false
    var reminderTime: Date = Date()
    var type: HabitType = HabitType.simple
    var goal: Int = 1
    var unit: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]? = []
    
    private var frequencyType: FrequencyType = FrequencyType.daily
    private var frequencyDays: [Int] = []

    var safeLogs: [HabitLog] {
        logs ?? []
    }

    @Transient
    var frequency: HabitFrequency {
        get {
            switch frequencyType {
            case .daily:
                return .daily
            case .weekly:
                let weekdays = Set(frequencyDays.compactMap { Weekday(rawValue: $0) })
                return .weekly(weekdays)
            }
        }
        set {
            switch newValue {
            case .daily:
                frequencyType = .daily
                frequencyDays = []
            case .weekly(let weekdays):
                frequencyType = .weekly
                frequencyDays = weekdays.map { $0.rawValue }.sorted()
            }
        }
    }
    
    /// Calcula la racha actual de días consecutivos en que se ha completado el hábito.
    var currentStreak: Int {
        var streak = 0
        let currentDate = Date.now
        let calendar = Calendar.current
        
        for i in 0..<safeLogs.count + 1 {
            let dateToCheck = calendar.date(byAdding: .day, value: -i, to: currentDate)!
            
            if isCompleted(on: dateToCheck) {
                streak += 1
            } else {
                if !calendar.isDateInToday(dateToCheck) {
                    break
                }
            }
        }
        
        return streak
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        description: String = "",
        frequency: HabitFrequency = .daily,
        creationDate: Date = .now,
        reminderEnabled: Bool = false,
        reminderTime: Date = Date(),
        type: HabitType = .simple,
        goal: Int = 1,
        unit: String = ""
    ) {
        self.id = id
        self.name = name
        self.habitDescription = description
        self.frequency = frequency
        self.creationDate = creationDate
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.type = type
        self.goal = goal
        self.unit = unit
        self.logs = []
    }
    
    func isCompleted(on date: Date) -> Bool {
        guard let logOnDate = safeLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return false
        }
        
        switch type {
        case .simple:
            return logOnDate.progress > 0
        case .quantitative:
            return logOnDate.progress >= goal
        }
    }
    
    func completionPercentage(forLast days: Int) -> Double {
        let calendar = Calendar.current
        let endDate = Date.now
        guard calendar.date(byAdding: .day, value: -days, to: endDate) != nil else {
            return 0.0
        }
        
        var scheduledCount = 0
        var completedCount = 0
        
        for i in 0...days {
            guard let dateToCheck = calendar.date(byAdding: .day, value: -i, to: endDate) else { continue }
            if dateToCheck > endDate { continue }
            
            var wasScheduled = false
            
            switch self.frequency {
            case .daily:
                wasScheduled = true
            case .weekly(let weekdays):
                let weekday = calendar.component(.weekday, from: dateToCheck)
                if weekdays.contains(where: { $0.rawValue == weekday }) {
                    wasScheduled = true
                }
            }
            
            if wasScheduled {
                scheduledCount += 1
                if isCompleted(on: dateToCheck) {
                    completedCount += 1
                }
            }
        }
        
        if scheduledCount == 0 {
            return 0.0
        }
        
        return (Double(completedCount) / Double(scheduledCount)) * 100.0
    }
}

extension Habit {
    var todaysLog: HabitLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return safeLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: today)
        }
    }
    
    var todaysProgress: Int {
        todaysLog?.progress ?? 0
    }
    
    var isCompletedToday: Bool {
        switch type {
        case .simple:
            return todaysProgress > 0
        case .quantitative:
            return todaysProgress >= goal
        }
    }
}
