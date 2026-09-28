import Foundation

public protocol GetHabitsUseCaseProtocol: Sendable {
    func execute() async throws -> [HabitEntity]
}

public struct GetHabitsUseCase: GetHabitsUseCaseProtocol {
    private let repository: HabitRepositoryProtocol
    
    public init(repository: HabitRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> [HabitEntity] {
        try await repository.getHabits()
    }
}
