import Foundation

public enum FrequencyType: String, Codable, Sendable {
    case daily
    case weekly
}

public enum HabitFrequency: Codable, Hashable, Sendable {
    case daily
    case weekly(Set<Weekday>)
    
    public var description: String {
        switch self {
        case .daily:
            return "Diario"
        case .weekly(let days):
            if days.count == 7 { return "Diario" }
            if days.isEmpty { return "Ningún día" }
            return days.sorted().map { $0.initial }.joined(separator: ", ")
        }
    }

    public enum Case: Hashable, Sendable {
        case daily, weekly
    }

    public var `case`: Case {
        switch self {
        case .daily: return .daily
        case .weekly: return .weekly
        }
    }
}
