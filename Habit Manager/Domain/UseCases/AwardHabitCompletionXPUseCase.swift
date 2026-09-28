import Foundation

public protocol AwardHabitCompletionXPUseCaseProtocol: Sendable {
    func execute(isCompleted: Bool, isQuantitative: Bool) async throws -> Int
}

public struct AwardHabitCompletionXPUseCase: AwardHabitCompletionXPUseCaseProtocol {
    private let gamificationRepository: GamificationRepositoryProtocol
    
    public init(gamificationRepository: GamificationRepositoryProtocol) {
        self.gamificationRepository = gamificationRepository
    }
    
    public func execute(isCompleted: Bool, isQuantitative: Bool) async throws -> Int {
        guard isCompleted else { return 0 }
        let xp = isQuantitative ? 15 : 10
        return try await gamificationRepository.addXP(amount: xp)
    }
}
