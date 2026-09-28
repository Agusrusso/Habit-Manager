import Foundation

public enum Weekday: Int, Codable, CaseIterable, Comparable, Sendable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    public static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// La inicial para mostrar en la UI.
    public var initial: String {
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
