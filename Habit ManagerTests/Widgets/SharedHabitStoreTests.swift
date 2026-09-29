import Foundation
import Testing
@testable import Habit_Manager

@Suite("SharedHabitStore Tests")
struct SharedHabitStoreTests {
    
    @Test("Snapshot encoding and decoding works with custom userDefaults")
    func snapshotSaveAndLoad() {
        let testSuiteName = "test_shared_habit_store_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: testSuiteName)!
        defer { defaults.removePersistentDomain(forName: testSuiteName) }
        
        let store = SharedHabitStore(userDefaults: defaults)
        
        let habit1 = HabitWidgetItem(
            id: UUID(),
            name: "Hábito 1",
            isCompleted: false,
            currentStreak: 2,
            progress: 0,
            goal: 1,
            unit: "",
            isQuantitative: false
        )
        let habit2 = HabitWidgetItem(
            id: UUID(),
            name: "Hábito 2",
            isCompleted: true,
            currentStreak: 5,
            progress: 8,
            goal: 8,
            unit: "vasos",
            isQuantitative: true
        )
        
        let snapshot = HabitWidgetSnapshot(habits: [habit1, habit2], highestStreak: 5)
        store.saveSnapshot(snapshot)
        
        let loaded = store.loadSnapshot()
        #expect(loaded.totalCount == 2)
        #expect(loaded.completedCount == 1)
        #expect(loaded.completionPercentage == 50.0)
        #expect(loaded.highestStreak == 5)
        #expect(loaded.habits.first?.name == "Hábito 1")
    }
    
    @Test("Toggling habit in snapshot flips completion and adjusts progress and streak")
    func toggleHabitInSnapshot() {
        let testSuiteName = "test_shared_habit_store_toggle_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: testSuiteName)!
        defer { defaults.removePersistentDomain(forName: testSuiteName) }
        
        let store = SharedHabitStore(userDefaults: defaults)
        let habitId = UUID()
        let habit = HabitWidgetItem(
            id: habitId,
            name: "Meditar",
            isCompleted: false,
            currentStreak: 3,
            progress: 0,
            goal: 1,
            unit: "",
            isQuantitative: false
        )
        
        store.saveSnapshot(HabitWidgetSnapshot(habits: [habit], highestStreak: 3))
        
        let updated = store.toggleHabit(id: habitId)
        let toggledHabit = updated.habits.first { $0.id == habitId }
        #expect(toggledHabit?.isCompleted == true)
        #expect(toggledHabit?.currentStreak == 4)
        #expect(toggledHabit?.progress == 1)
        #expect(updated.completedCount == 1)
        #expect(updated.completionPercentage == 100.0)
        
        let toggledBack = store.toggleHabit(id: habitId)
        let backHabit = toggledBack.habits.first { $0.id == habitId }
        #expect(backHabit?.isCompleted == false)
        #expect(backHabit?.currentStreak == 3)
        #expect(backHabit?.progress == 0)
        #expect(toggledBack.completedCount == 0)
        #expect(toggledBack.completionPercentage == 0.0)
    }
    
    @Test("Empty store returns empty snapshot gracefully")
    func emptyStoreReturnsEmptySnapshot() {
        let testSuiteName = "test_empty_store_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: testSuiteName)!
        defer { defaults.removePersistentDomain(forName: testSuiteName) }
        
        let store = SharedHabitStore(userDefaults: defaults)
        let snapshot = store.loadSnapshot()
        #expect(snapshot.totalCount == 0)
        #expect(snapshot.completedCount == 0)
        #expect(snapshot.completionPercentage == 0.0)
        #expect(snapshot.habits.isEmpty)
    }
}
