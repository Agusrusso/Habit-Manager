import Foundation
import SwiftData

@Model
final class HabitLog {
    var date: Date = Date()
    var progress: Int = 0
    var habit: Habit?

    init(date: Date = Date(), progress: Int = 0) {
        self.date = date
        self.progress = progress
    }
}
