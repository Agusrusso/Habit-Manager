import Foundation

public protocol GetTodaysHabitsUseCaseProtocol: Sendable {
    func execute(for date: Date) async throws -> [HabitEntity]
}

public struct GetTodaysHabitsUseCase: GetTodaysHabitsUseCaseProtocol {
    private let repository: HabitRepositoryProtocol
    private let calendar: Calendar
    
    public init(repository: HabitRepositoryProtocol, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func execute(for date: Date = .now) async throws -> [HabitEntity] {
        let allHabits = try await repository.getHabits()
        return allHabits.filter { $0.isScheduled(on: date, calendar: calendar) }
    }
}
