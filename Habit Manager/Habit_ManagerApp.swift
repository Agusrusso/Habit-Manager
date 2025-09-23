import SwiftUI
import SwiftData

@main
struct Habit_ManagerApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                // Pestaña 1: Vista "Hoy" (la principal)
                TodayView()
                    .tabItem {
                        Label("Hoy", systemImage: "sun.max.fill")
                    }
                
                // Pestaña 2: Lista completa de hábitos
                HabitListView()
                    .tabItem {
                        Label("Todos", systemImage: "list.bullet")
                    }
            }
        }
        .modelContainer(for: [Habit.self, HabitLog.self])
    }
}
