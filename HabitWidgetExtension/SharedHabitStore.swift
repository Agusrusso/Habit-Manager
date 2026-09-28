import Foundation
import WidgetKit

public final class SharedHabitStore: @unchecked Sendable {
    public static let shared = SharedHabitStore()
    
    public static let appGroupName = "group.com.agusrusso.HabitManager"
    private static let snapshotKey = "habit_widget_snapshot_data"
    
    private let userDefaults: UserDefaults
    private let lock = NSLock()
    
    public init(userDefaults: UserDefaults? = nil) {
        if let userDefaults {
            self.userDefaults = userDefaults
        } else if let groupDefaults = UserDefaults(suiteName: Self.appGroupName) {
            self.userDefaults = groupDefaults
        } else {
            self.userDefaults = .standard
        }
    }
    
    public func saveSnapshot(_ snapshot: HabitWidgetSnapshot) {
        lock.lock()
        defer { lock.unlock() }
        
        do {
            let data = try JSONEncoder().encode(snapshot)
            userDefaults.set(data, forKey: Self.snapshotKey)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error encoding habit widget snapshot: \(error.localizedDescription)")
        }
    }
    
    public func loadSnapshot() -> HabitWidgetSnapshot {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = userDefaults.data(forKey: Self.snapshotKey) else {
            return .empty
        }
        
        do {
            return try JSONDecoder().decode(HabitWidgetSnapshot.self, from: data)
        } catch {
            print("Error decoding habit widget snapshot: \(error.localizedDescription)")
            return .empty
        }
    }
    
    @discardableResult
    public func toggleHabit(id: UUID) -> HabitWidgetSnapshot {
        lock.lock()
        defer { lock.unlock() }
        
        var current = loadSnapshotUnlocked()
        let updatedHabits = current.habits.map { item -> HabitWidgetItem in
            guard item.id == id else { return item }
            let newCompleted = !item.isCompleted
            let newProgress = item.isQuantitative ? (newCompleted ? item.goal : 0) : (newCompleted ? 1 : 0)
            let newStreak = newCompleted ? item.currentStreak + 1 : max(0, item.currentStreak - 1)
            return HabitWidgetItem(
                id: item.id,
                name: item.name,
                habitDescription: item.habitDescription,
                isCompleted: newCompleted,
                currentStreak: newStreak,
                progress: newProgress,
                goal: item.goal,
                unit: item.unit,
                isQuantitative: item.isQuantitative
            )
        }
        
        let newHighestStreak = updatedHabits.map(\.currentStreak).max() ?? current.highestStreak
        let updatedSnapshot = HabitWidgetSnapshot(
            habits: updatedHabits,
            highestStreak: newHighestStreak,
            lastUpdated: .now
        )
        
        if let data = try? JSONEncoder().encode(updatedSnapshot) {
            userDefaults.set(data, forKey: Self.snapshotKey)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        return updatedSnapshot
    }
    
    private func loadSnapshotUnlocked() -> HabitWidgetSnapshot {
        guard let data = userDefaults.data(forKey: Self.snapshotKey),
              let decoded = try? JSONDecoder().decode(HabitWidgetSnapshot.self, from: data) else {
            return .empty
        }
        return decoded
    }
}
