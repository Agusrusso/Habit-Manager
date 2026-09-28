import Foundation

public struct HabitEntity: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var habitDescription: String
    public var creationDate: Date
    public var frequency: HabitFrequency
    public var reminderEnabled: Bool
    public var reminderTime: Date
    public var type: HabitType
    public var goal: Int
    public var unit: String
    public var logs: [HabitLogEntity]
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        frequency: HabitFrequency = .daily,
        creationDate: Date = .now,
        reminderEnabled: Bool = false,
        reminderTime: Date = Date(),
        type: HabitType = .simple,
        goal: Int = 1,
        unit: String = "",
        logs: [HabitLogEntity] = []
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
        self.logs = logs
    }
    
    public func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        switch frequency {
        case .daily:
            return true
        case .weekly(let weekdays):
            let weekday = calendar.component(.weekday, from: date)
            return weekdays.contains { $0.rawValue == weekday }
        }
    }
    
    public func log(on date: Date, calendar: Calendar = .current) -> HabitLogEntity? {
        logs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    public func progress(on date: Date, calendar: Calendar = .current) -> Int {
        log(on: date, calendar: calendar)?.progress ?? 0
    }
    
    public func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        let currentProgress = progress(on: date, calendar: calendar)
        switch type {
        case .simple:
            return currentProgress > 0
        case .quantitative:
            return currentProgress >= goal
        }
    }
    
    public func currentStreak(at referenceDate: Date = .now, calendar: Calendar = .current) -> Int {
        var streak = 0
        let maxDaysToCheck = max(logs.count + 1, 365)
        
        for i in 0..<maxDaysToCheck {
            guard let dateToCheck = calendar.date(byAdding: .day, value: -i, to: referenceDate) else {
                break
            }
            
            if isCompleted(on: dateToCheck, calendar: calendar) {
                streak += 1
            } else {
                if !calendar.isDateInToday(dateToCheck) && !calendar.isDate(dateToCheck, inSameDayAs: referenceDate) {
                    break
                }
            }
        }
        
        return streak
    }
    
    public func completionPercentage(
        forLast days: Int,
        endingAt endDate: Date = .now,
        calendar: Calendar = .current
    ) -> Double {
        guard days > 0 else { return 0.0 }
        
        var scheduledCount = 0
        var completedCount = 0
        
        for i in 0..<days {
            guard let dateToCheck = calendar.date(byAdding: .day, value: -i, to: endDate) else { continue }
            if dateToCheck > endDate { continue }
            
            if isScheduled(on: dateToCheck, calendar: calendar) {
                scheduledCount += 1
                if isCompleted(on: dateToCheck, calendar: calendar) {
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
