import Foundation

public enum HabitDomainError: Error, LocalizedError, Equatable {
    case habitNotFound(UUID)
    case invalidHabitData(String)
    case repositoryFailure(String)
    
    public var errorDescription: String? {
        switch self {
        case .habitNotFound(let id):
            return "No se encontró el hábito con ID \(id)."
        case .invalidHabitData(let reason):
            return "Datos del hábito no válidos: \(reason)"
        case .repositoryFailure(let reason):
            return "Error en el repositorio: \(reason)"
        }
    }
}
