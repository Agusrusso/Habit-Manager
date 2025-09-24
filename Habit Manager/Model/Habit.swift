import Foundation
import SwiftData

// ===================================
// MARK: - Enums de Frecuencia
// ===================================

/// Representa un día de la semana de forma segura.
enum Weekday: Int, Codable, CaseIterable, Comparable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    /// Permite ordenar los días correctamente (ej. Lunes antes que Martes).
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
        let sortedLogs = logs.sorted { $0.date > $1.date }
        guard !sortedLogs.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date.now

        if let mostRecentLog = sortedLogs.first, calendar.isDate(mostRecentLog.date, inSameDayAs: currentDate) {
            streak += 1
            // Si se completó hoy, empezamos a contar desde ayer
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        } else if !calendar.isDateInToday(sortedLogs.first!.date) {
            // Si el último log no es de hoy ni de ayer, la racha se rompio
            if !calendar.isDateInYesterday(sortedLogs.first!.date) {
                return 0
            }
        }

        for log in sortedLogs.dropFirst() {
            if calendar.isDate(log.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                // En cuanto un día no coincide, la racha termina
                break
            }
        }
        
        return streak
    }
    
    init(id: UUID = UUID(), name: String, description: String, frequency: HabitFrequency, creationDate: Date = .now, reminderEnabled: Bool = false, reminderTime: Date = Date()) {
            self.id = id
            self.name = name
            self.habitDescription = description
            self.creationDate = creationDate
            self.frequency = frequency
            self.reminderEnabled = reminderEnabled
            self.reminderTime = reminderTime
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
    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.contains { log in
            Calendar.current.isDate(log.date, inSameDayAs: today)
        }
    }
}
