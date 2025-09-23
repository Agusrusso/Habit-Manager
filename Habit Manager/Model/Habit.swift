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

/// Enum lógico para usar en la app. No se guarda directamente.
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

/// Enum simple que SÍ se guarda en la base de datos.
enum FrequencyType: String, Codable {
    case daily
    case weekly
}

// ===================================
// MARK: - Modelo Principal
// ===================================

@Model
final class Habit {
    var name: String
    var habitDescription: String
    var creationDate: Date
    
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
    
    init(name: String, description: String, frequency: HabitFrequency, creationDate: Date = .now) {
        self.name = name
        self.habitDescription = description
        self.creationDate = creationDate
        self.frequency = frequency
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
