import SwiftUI
import SwiftData

@main
struct Habit_ManagerApp: App {
    @State private var container: AppDependencyContainer
    
    init() {
        let schema = Schema([Habit.self, HabitLog.self])
        
        if CommandLine.arguments.contains("-ui-testing") {
            let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                let modelContainer = try ModelContainer(for: schema, configurations: [memoryConfig])
                let repository = SwiftDataHabitRepository(modelContainer: modelContainer)
                let notificationService = AppNotificationService.shared
                let suiteName = "UITestingSuite"
                let userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
                userDefaults.removePersistentDomain(forName: suiteName)
                let gamificationRepository = UserDefaultsGamificationRepository(userDefaults: userDefaults)
                _container = State(initialValue: AppDependencyContainer(
                    repository: repository,
                    notificationService: notificationService,
                    gamificationRepository: gamificationRepository
                ))
                return
            } catch {
                fatalError("Error crítico al inicializar ModelContainer en memoria para UI testing: \(error.localizedDescription)")
            }
        }
        
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
                TodayView(viewModel: container.makeTodayViewModel())
                    .tabItem {
                        Label("Hoy", systemImage: "sun.max.fill")
                    }
                
                HabitListView(viewModel: container.makeHabitListViewModel())
                    .tabItem {
                        Label("Todos", systemImage: "list.bullet")
                    }
                
                AchievementsView(viewModel: container.makeGamificationViewModel())
                    .tabItem {
                        Label("Logros", systemImage: "trophy.fill")
                    }
                
                StatsView(viewModel: container.makeStatsViewModel())
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.bar.fill")
                    }
            }
            .environment(\.dependencyContainer, container)
            .task {
                if !CommandLine.arguments.contains("-ui-testing") {
                    _ = await container.notificationService.requestAuthorization()
                }
            }
        }
    }
}
