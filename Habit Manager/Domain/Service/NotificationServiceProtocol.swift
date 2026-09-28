import Foundation

public protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleNotification(for habit: HabitEntity) async
    func cancelNotification(for habitId: UUID) async
}
