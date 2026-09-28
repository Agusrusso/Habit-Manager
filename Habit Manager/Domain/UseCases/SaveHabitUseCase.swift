import Foundation

public protocol SaveHabitUseCaseProtocol: Sendable {
    func execute(_ habit: HabitEntity) async throws
}

public struct SaveHabitUseCase: SaveHabitUseCaseProtocol {
    private let repository: HabitRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    
    public init(
        repository: HabitRepositoryProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.repository = repository
        self.notificationService = notificationService
    }
    
    public func execute(_ habit: HabitEntity) async throws {
        guard !habit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw HabitDomainError.invalidHabitData("El nombre del hábito no puede estar vacío.")
        }
        
        try await repository.saveHabit(habit)
        
        if habit.reminderEnabled {
            await notificationService.scheduleNotification(for: habit)
        } else {
            await notificationService.cancelNotification(for: habit.id)
        }
    }
}
