import Foundation

public enum AchievementCategory: String, CaseIterable, Sendable, Identifiable {
    case gettingStarted = "Primeros Pasos"
    case streaks = "Rachas de Fuego"
    case mastery = "Constancia"
    case quantitative = "Metas Numéricas"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .gettingStarted:
            return "figure.walk"
        case .streaks:
            return "flame.fill"
        case .mastery:
            return "crown.fill"
        case .quantitative:
            return "chart.line.uptrend.xyaxis"
        }
    }
}
