import Foundation

public protocol DeleteHabitUseCaseProtocol: Sendable {
    func execute(habitId: UUID) async throws
}

public struct DeleteHabitUseCase: DeleteHabitUseCaseProtocol {
    private let repository: HabitRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    
    public init(
        repository: HabitRepositoryProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.repository = repository
        self.notificationService = notificationService
    }
    
    public func execute(habitId: UUID) async throws {
        await notificationService.cancelNotification(for: habitId)
        try await repository.deleteHabit(byId: habitId)
    }
}
