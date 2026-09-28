import Foundation

public enum AchievementType: String, CaseIterable, Sendable, Identifiable {
    // Primeros pasos
    case firstHabitCreated = "first_habit_created"
    case firstHabitCompleted = "first_habit_completed"
    
    // Rachas
    case streak3Days = "streak_3_days"
    case streak7Days = "streak_7_days"
    case streak14Days = "streak_14_days"
    case streak21Days = "streak_21_days"
    case streak30Days = "streak_30_days"
    case streak100Days = "streak_100_days"
    
    // Constancia y Maestría
    case perfectDay = "perfect_day"
    case tenCompletions = "ten_completions"
    case fiftyCompletions = "fifty_completions"
    case centurion = "centurion_100_completions"
    
    // Metas Numéricas
    case quantitativeFirstGoal = "quantitative_first_goal"
    case quantitativeMaster = "quantitative_master"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .firstHabitCreated:
            return "Primer Paso"
        case .firstHabitCompleted:
            return "Punto de Partida"
        case .streak3Days:
            return "Chispa"
        case .streak7Days:
            return "Llama Viva"
        case .streak14Days:
            return "Hoguera"
        case .streak21Days:
            return "Hábito Forjado"
        case .streak30Days:
            return "Imparable"
        case .streak100Days:
            return "Hábito de Hierro"
        case .perfectDay:
            return "Día Perfecto"
        case .tenCompletions:
            return "Primeros Diez"
        case .fiftyCompletions:
            return "Medio Centenar"
        case .centurion:
            return "Centurión"
        case .quantitativeFirstGoal:
            return "Meta Cumplida"
        case .quantitativeMaster:
            return "Medición Implacable"
        }
    }
    
    public var description: String {
        switch self {
        case .firstHabitCreated:
            return "Crea tu primer hábito en la aplicación."
        case .firstHabitCompleted:
            return "Completa tu primer hábito."
        case .streak3Days:
            return "Alcanza una racha de 3 días consecutivos en cualquier hábito."
        case .streak7Days:
            return "Alcanza una racha de 7 días consecutivos en cualquier hábito."
        case .streak14Days:
            return "Alcanza una racha de 14 días consecutivos en cualquier hábito."
        case .streak21Days:
            return "Alcanza 21 días de racha (el tiempo para forjar un hábito)."
        case .streak30Days:
            return "Alcanza 30 días de racha consecutiva."
        case .streak100Days:
            return "¡Alcanza 100 días de racha consecutiva! Nivel legendario."
        case .perfectDay:
            return "Completa todos tus hábitos programados en un solo día (mínimo 3)."
        case .tenCompletions:
            return "Alcanza un total de 10 hábitos completados."
        case .fiftyCompletions:
            return "Alcanza un total de 50 hábitos completados."
        case .centurion:
            return "Alcanza un total de 100 hábitos completados."
        case .quantitativeFirstGoal:
            return "Alcanza la meta diaria de un hábito cuantitativo."
        case .quantitativeMaster:
            return "Alcanza la meta cuantitativa 20 veces."
        }
    }
    
    public var iconName: String {
        switch self {
        case .firstHabitCreated:
            return "sparkles"
        case .firstHabitCompleted:
            return "checkmark.seal.fill"
        case .streak3Days:
            return "flame"
        case .streak7Days:
            return "flame.fill"
        case .streak14Days:
            return "bolt.fill"
        case .streak21Days:
            return "star.circle.fill"
        case .streak30Days:
            return "shield.lefthalf.filled.badge.checkmark"
        case .streak100Days:
            return "trophy.fill"
        case .perfectDay:
            return "sun.max.fill"
        case .tenCompletions:
            return "number.circle.fill"
        case .fiftyCompletions:
            return "rosette"
        case .centurion:
            return "medal.fill"
        case .quantitativeFirstGoal:
            return "target"
        case .quantitativeMaster:
            return "chart.bar.xaxis.ascending"
        }
    }
    
    public var category: AchievementCategory {
        switch self {
        case .firstHabitCreated, .firstHabitCompleted:
            return .gettingStarted
        case .streak3Days, .streak7Days, .streak14Days, .streak21Days, .streak30Days, .streak100Days:
            return .streaks
        case .perfectDay, .tenCompletions, .fiftyCompletions, .centurion:
            return .mastery
        case .quantitativeFirstGoal, .quantitativeMaster:
            return .quantitative
        }
    }
    
    public var targetProgress: Int {
        switch self {
        case .firstHabitCreated, .firstHabitCompleted, .perfectDay, .quantitativeFirstGoal:
            return 1
        case .streak3Days:
            return 3
        case .streak7Days:
            return 7
        case .streak14Days:
            return 14
        case .streak21Days:
            return 21
        case .streak30Days:
            return 30
        case .streak100Days:
            return 100
        case .tenCompletions:
            return 10               
        case .fiftyCompletions:
            return 50
        case .centurion:
            return 100
        case .quantitativeMaster:
            return 20
        }
    }
    
    public var xpReward: Int {
        switch self {
        case .firstHabitCreated:
            return 20
        case .firstHabitCompleted:
            return 30
        case .streak3Days:
            return 50
        case .streak7Days:
            return 100
        case .streak14Days:
            return 150
        case .streak21Days:
            return 250
        case .streak30Days:
            return 400
        case .streak100Days:
            return 1000
        case .perfectDay:
            return 100
        case .tenCompletions:
            return 75
        case .fiftyCompletions:
            return 200
        case .centurion:
            return 500
        case .quantitativeFirstGoal:
            return 40
        case .quantitativeMaster:
            return 200
        }
    }
}
