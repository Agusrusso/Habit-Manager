import Foundation
import UserNotifications

public final class AppNotificationService: NotificationServiceProtocol {
    public static let shared = AppNotificationService()
    
    private let notificationCenter: UNUserNotificationCenter
    
    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }
    
    public func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            return false
        }
    }
    
    public func scheduleNotification(for habit: HabitEntity) async {
        await cancelNotification(for: habit.id)
        
        guard habit.reminderEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "¡Es hora de tu hábito!"
        content.body = habit.name
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: habit.reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            print("Notificación programada para el hábito: \(habit.name)")
        } catch {
            print("Error al programar la notificación: \(error.localizedDescription)")
        }
    }
    
    public func cancelNotification(for habitId: UUID) async {
        let identifier = habitId.uuidString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notificación cancelada para el identificador: \(identifier)")
    }
}
