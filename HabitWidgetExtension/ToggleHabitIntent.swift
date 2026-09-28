import Foundation
import AppIntents

public struct ToggleHabitIntent: AppIntent {
    public static var title: LocalizedStringResource = "Alternar Hábito"
    public static var description = IntentDescription("Marca o desmarca un hábito desde el widget interactivo.")
    
    @Parameter(title: "ID del Hábito")
    public var habitId: String
    
    public init() {
        self.habitId = ""
    }
    
    public init(habitId: UUID) {
        self.habitId = habitId.uuidString
    }
    
    public init(habitId: String) {
        self.habitId = habitId
    }
    
    public func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: habitId) else {
            return .result()
        }
        
        SharedHabitStore.shared.toggleHabit(id: uuid)
        return .result()
    }
}
