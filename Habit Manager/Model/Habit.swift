import Foundation
import SwiftUI
import SwiftData

// ===================================
// MARK: - Enums de Frecuencia
// ===================================

enum Weekday: Int, Codable, CaseIterable, Comparable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// La inicial para mostrar en la UI.
    var initial: String {
        switch self {
        case .sunday: return "D"
        case .monday: return "L"
        case .tuesday: return "M"
        case .wednesday: return "X"
        case .thursday: return "J"
        case .friday: return "V"
        case .saturday: return "S"
        }
    }
}

/// Enum lógico para usar en la app que no se guarda directamente.
enum HabitFrequency: Codable {
    case daily
    case weekly(Set<Weekday>)
    
    var description: String {
        switch self {
        case .daily:
            return "Diario"
        case .weekly(let days):
            if days.count == 7 { return "Diario" }
            if days.isEmpty { return "Ningún día" }
            return days.sorted().map { $0.initial }.joined(separator: ", ")
        }
    }
}

/// Enum simple que si se guarda en la base de datos.
enum FrequencyType: String, Codable {
    case daily
    case weekly
}

enum HabitType: String, Codable {
    case simple
    case quantitative
}

// ===================================
// MARK: - Modelo Principal
// ===================================

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    
    var name: String
    var habitDescription: String
    var creationDate: Date
    var reminderEnabled: Bool = false
    var reminderTime: Date = Date()
    var type: HabitType = HabitType.simple
    var goal: Int = 1 // Meta para hábitos cuantitativos
    var unit: String = "" // ej: "vasos", "minutos", "pasos"
    
    @Relationship(deleteRule: .cascade) var logs: [HabitLog] = []
    
    private var frequencyType: FrequencyType = FrequencyType.daily
    private var frequencyDays: [Int] = []

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
        
        for i in 0..<logs.count + 1 { // límite de seguridad para no entrar en un bucle infinito
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
    
    init(id: UUID = UUID(), name: String, description: String, frequency: HabitFrequency, creationDate: Date = .now, reminderEnabled: Bool = false, reminderTime: Date = Date(), type: HabitType = .simple, goal: Int = 1, unit: String = "") {
        self.id = id
        self.name = name
        self.habitDescription = description
        self.creationDate = creationDate
        self.frequency = frequency
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.type = type
        self.goal = goal
        self.unit = unit
    }
    
    func isCompleted(on date: Date) -> Bool {
        guard let logOnDate = logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
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
        // 1. Definimos el rango de fechas a revisar.
        let endDate = Date.now
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return 0.0
        }
        
        var scheduledCount = 0
        var completedCount = 0
        
        // 2. Iteramos día por día dentro del rango.
        for i in 0...days {
            guard let dateToCheck = calendar.date(byAdding: .day, value: -i, to: endDate) else { continue }
            
            // No contamos días futuros si el rango es grande (poco probable, pero seguro).
            if dateToCheck > endDate { continue }
            
            var wasScheduled = false
            
            // 3. Verificamos si el hábito estaba programado para ese día.
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
                // 4. Si estaba programado, verificamos si se completó.
                if isCompleted(on: dateToCheck) {
                    completedCount += 1
                }
            }
        }
        
        // 5. Calculamos el porcentaje, evitando la división por cero.
        if scheduledCount == 0 {
            return 0.0
        }
        
        return (Double(completedCount) / Double(scheduledCount)) * 100.0
    }
}


// ===================================
// MARK: - Convenience Extension
// ===================================

extension HabitFrequency {
    enum Case: Hashable {
        case daily, weekly
    }

    var `case`: Case {
        switch self {
        case .daily: return .daily
        case .weekly: return .weekly
        }
    }
}

extension Habit {
    var todaysLog: HabitLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { log in
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
