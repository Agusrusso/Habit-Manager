import SwiftUI
import SwiftData

@main
struct Habit_ManagerApp: App {
    @State private var container: AppDependencyContainer
    
    init() {
        do {
            let modelContainer = try ModelContainer(for: Habit.self, HabitLog.self)
            _container = State(initialValue: AppDependencyContainer(modelContainer: modelContainer))
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                // Pestaña 1: "Hoy" (main)
                TodayView(viewModel: container.makeTodayViewModel())
                    .tabItem {
                        Label("Hoy", systemImage: "sun.max.fill")
                    }
                
                // Pestaña 2: Lista completa de hábitos
                HabitListView(viewModel: container.makeHabitListViewModel())
                    .tabItem {
                        Label("Todos", systemImage: "list.bullet")
                    }
                
                // Pestaña 3: Estadísticas
                StatsView(viewModel: container.makeStatsViewModel())
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.bar.fill")
                    }
            }
            .environment(\.dependencyContainer, container)
            .task {
                _ = await container.notificationService.requestAuthorization()
            }
        }
    }
}
