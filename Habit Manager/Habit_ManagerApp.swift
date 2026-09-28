import SwiftUI
import SwiftData

@main
struct Habit_ManagerApp: App {
    @State private var container: AppDependencyContainer
    
    init() {
        let schema = Schema([Habit.self, HabitLog.self])
        
        do {
            // Intenta inicializar con sincronización de CloudKit si los entitlements están activos
            let cloudConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
            let modelContainer = try ModelContainer(for: schema, configurations: [cloudConfig])
            _container = State(initialValue: AppDependencyContainer(modelContainer: modelContainer))
        } catch {
            // Fallback seguro a almacenamiento local cuando no hay credenciales/entitlements de CloudKit
            do {
                let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
                let modelContainer = try ModelContainer(for: schema, configurations: [localConfig])
                _container = State(initialValue: AppDependencyContainer(modelContainer: modelContainer))
            } catch {
                fatalError("Error crítico al inicializar ModelContainer local: \(error.localizedDescription)")
            }
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
                
                // Pestaña 3: Logros y Gamificación
                AchievementsView(viewModel: container.makeGamificationViewModel())
                    .tabItem {
                        Label("Logros", systemImage: "trophy.fill")
                    }
                
                // Pestaña 4: Estadísticas
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
