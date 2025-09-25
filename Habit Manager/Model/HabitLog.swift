import Foundation
import SwiftData

@Model
final class HabitLog {
    var date: Date
    var progress: Int = 0
    var habit: Habit?

    init(date: Date, progress: Int) {
        self.date = date
        self.progress = progress
    }
}
