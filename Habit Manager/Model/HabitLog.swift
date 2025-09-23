import Foundation
import SwiftData

@Model
final class HabitLog {
    var date: Date
    var isCompleted: Bool
    
    var habit: Habit?

    init(date: Date, isCompleted: Bool = true) {
        self.date = date
        self.isCompleted = isCompleted
    }
}
