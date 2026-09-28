import Foundation

public protocol HabitRepositoryProtocol: Sendable {
    func getHabits() async throws -> [HabitEntity]
    func getHabit(byId id: UUID) async throws -> HabitEntity?
    func saveHabit(_ habit: HabitEntity) async throws
    func deleteHabit(byId id: UUID) async throws
    func updateProgress(habitId: UUID, date: Date, progress: Int) async throws -> HabitEntity
}
