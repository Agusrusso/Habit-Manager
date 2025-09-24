import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permiso de notificaciones concedido.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleNotification(for habit: Habit) {
        cancelNotification(for: habit)
        
        guard habit.reminderEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "¡Es hora de tu hábito!"
        content.body = habit.name
        content.sound = .default

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: habit.reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al programar la notificación: \(error.localizedDescription)")
            } else {
                print("Notificación programada para el hábito: \(habit.name)")
            }
        }
    }
    
    func cancelNotification(for habit: Habit) {
        let identifier = habit.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notificación cancelada para el hábito: \(habit.name)")
    }
}
