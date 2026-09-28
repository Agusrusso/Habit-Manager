import Foundation
import Testing
@testable import Habit_Manager

@Suite("HabitActivityAttributes Tests")
struct HabitActivityAttributesTests {
    @Test("Attributes and ContentState encode and decode properly")
    func encodeAndDecodeAttributes() throws {
        let habitId = UUID()
        let attributes = HabitActivityAttributes(
            habitId: habitId,
            habitName: "Meditación Zen",
            targetMinutes: 20,
            habitStreak: 5
        )
        
        #expect(attributes.habitId == habitId)
        #expect(attributes.habitName == "Meditación Zen")
        #expect(attributes.targetMinutes == 20)
        #expect(attributes.habitStreak == 5)
        
        let now = Date()
        let end = now.addingTimeInterval(1200)
        let state = HabitActivityAttributes.ContentState(
            startDate: now,
            endDate: end,
            isPaused: false,
            statusMessage: "Enfocado"
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(state)
        let decoded = try decoder.decode(HabitActivityAttributes.ContentState.self, from: data)
        
        #expect(decoded.isPaused == false)
        #expect(decoded.statusMessage == "Enfocado")
        #expect(abs(decoded.startDate.timeIntervalSince(now)) < 1.0)
        #expect(abs(decoded.endDate.timeIntervalSince(end)) < 1.0)
    }
}
