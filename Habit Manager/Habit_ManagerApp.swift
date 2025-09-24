import SwiftUI
import SwiftData

@main
struct Habit_ManagerApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                // Pestaña 1: "Hoy" (main)
                TodayView()
                    .tabItem {
                        Label("Hoy", systemImage: "sun.max.fill")
                    }
                
                // Pestaña 2: Lista completa de habitos
                HabitListView()
                    .tabItem {
                        Label("Todos", systemImage: "list.bullet")
                    }
                
                // Pestaña 3: Estadisticas
                StatsView()
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.bar.fill")
                    }
            }
            .onAppear(perform: NotificationManager.shared.requestAuthorization)
        }
        .modelContainer(for: [Habit.self, HabitLog.self])
    }
}
