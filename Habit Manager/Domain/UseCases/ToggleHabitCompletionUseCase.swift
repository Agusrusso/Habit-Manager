import Foundation

public protocol ToggleHabitCompletionUseCaseProtocol: Sendable {
    func execute(habitId: UUID, on date: Date) async throws -> HabitEntity
    func setProgress(habitId: UUID, on date: Date, progress: Int) async throws -> HabitEntity
}

public struct ToggleHabitCompletionUseCase: ToggleHabitCompletionUseCaseProtocol {
    private let repository: HabitRepositoryProtocol
    private let calendar: Calendar
    
    public init(repository: HabitRepositoryProtocol, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }
    
    public func execute(habitId: UUID, on date: Date = .now) async throws -> HabitEntity {
        guard let habit = try await repository.getHabit(byId: habitId) else {
            throw HabitDomainError.habitNotFound(habitId)
        }
        
        let currentProgress = habit.progress(on: date, calendar: calendar)
        let newProgress: Int
        
        switch habit.type {
        case .simple:
            newProgress = currentProgress > 0 ? 0 : 1
        case .quantitative:
            newProgress = currentProgress >= habit.goal ? 0 : habit.goal
        }
        
        return try await repository.updateProgress(habitId: habitId, date: date, progress: newProgress)
    }
    
    public func setProgress(habitId: UUID, on date: Date = .now, progress: Int) async throws -> HabitEntity {
        guard let _ = try await repository.getHabit(byId: habitId) else {
            throw HabitDomainError.habitNotFound(habitId)
        }
        let clampedProgress = max(0, progress)
        return try await repository.updateProgress(habitId: habitId, date: date, progress: clampedProgress)
    }
}
