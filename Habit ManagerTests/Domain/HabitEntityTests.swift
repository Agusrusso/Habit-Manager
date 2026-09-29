import Foundation
import Testing
@testable import Habit_Manager

@Suite("HabitEntity Business Logic Tests")
struct HabitEntityTests {
    private let calendar = Calendar.current
    
    private func date(daysAgo: Int, from base: Date = Date()) -> Date {
        calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysAgo, to: base)!)
    }
    
    @Test("Scheduling logic for daily habits")
    func dailyHabitIsScheduledEveryDay() {
        let habit = HabitEntity(name: "Meditar", frequency: .daily)
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        #expect(habit.isScheduled(on: today, calendar: calendar) == true)
        #expect(habit.isScheduled(on: tomorrow, calendar: calendar) == true)
    }
    
    @Test("Scheduling logic for weekly habits")
    func weeklyHabitIsScheduledOnlyOnSelectedDays() {
        let habit = HabitEntity(name: "Gimnasio", frequency: .weekly([.monday, .wednesday]))
        
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 9
        dateComponents.day = 28
        let monday = calendar.date(from: dateComponents)!
        let tuesday = calendar.date(byAdding: .day, value: 1, to: monday)!
        let wednesday = calendar.date(byAdding: .day, value: 2, to: monday)!
        
        #expect(habit.isScheduled(on: monday, calendar: calendar) == true)
        #expect(habit.isScheduled(on: tuesday, calendar: calendar) == false)
        #expect(habit.isScheduled(on: wednesday, calendar: calendar) == true)
    }
    
    @Test("Simple habit completion criteria")
    func simpleHabitCompletion() {
        let baseDate = Date()
        let habit = HabitEntity(
            name: "Leer",
            type: .simple,
            logs: [
                HabitLogEntity(date: date(daysAgo: 0, from: baseDate), progress: 1),
                HabitLogEntity(date: date(daysAgo: 1, from: baseDate), progress: 0)
            ]
        )
        
        #expect(habit.isCompleted(on: date(daysAgo: 0, from: baseDate), calendar: calendar) == true)
        #expect(habit.isCompleted(on: date(daysAgo: 1, from: baseDate), calendar: calendar) == false)
        #expect(habit.isCompleted(on: date(daysAgo: 2, from: baseDate), calendar: calendar) == false)
    }
    
    @Test("Quantitative habit completion criteria")
    func quantitativeHabitCompletion() {
        let baseDate = Date()
        let habit = HabitEntity(
            name: "Beber agua",
            type: .quantitative,
            goal: 8,
            unit: "vasos",
            logs: [
                HabitLogEntity(date: date(daysAgo: 0, from: baseDate), progress: 8),
                HabitLogEntity(date: date(daysAgo: 1, from: baseDate), progress: 5),
                HabitLogEntity(date: date(daysAgo: 2, from: baseDate), progress: 10)
            ]
        )
        
        #expect(habit.isCompleted(on: date(daysAgo: 0, from: baseDate), calendar: calendar) == true)
        #expect(habit.isCompleted(on: date(daysAgo: 1, from: baseDate), calendar: calendar) == false)
        #expect(habit.isCompleted(on: date(daysAgo: 2, from: baseDate), calendar: calendar) == true)
    }
    
    @Test("Streak calculation when completed today and past days")
    func streakCalculatesConsecutiveDays() {
        let baseDate = Date()
        let habit = HabitEntity(
            name: "Correr",
            type: .simple,
            logs: [
                HabitLogEntity(date: date(daysAgo: 0, from: baseDate), progress: 1),
                HabitLogEntity(date: date(daysAgo: 1, from: baseDate), progress: 1),
                HabitLogEntity(date: date(daysAgo: 2, from: baseDate), progress: 1),
                HabitLogEntity(date: date(daysAgo: 4, from: baseDate), progress: 1)
            ]
        )
        
        #expect(habit.currentStreak(at: baseDate, calendar: calendar) == 3)
    }
    
    @Test("Streak calculation maintains streak if today is not yet completed but yesterday was")
    func streakMaintainsIfTodayIncomplete() {
        let baseDate = Date()
        let habit = HabitEntity(
            name: "Estudiar",
            type: .simple,
            logs: [
                HabitLogEntity(date: date(daysAgo: 1, from: baseDate), progress: 1),
                HabitLogEntity(date: date(daysAgo: 2, from: baseDate), progress: 1)
            ]
        )
        
        #expect(habit.currentStreak(at: baseDate, calendar: calendar) == 2)
    }
    
    @Test("Streak is 0 when yesterday was missed and today is not completed")
    func streakIsZeroWhenBroken() {
        let baseDate = Date()
        let habit = HabitEntity(
            name: "Estudiar",
            type: .simple,
            logs: [
                HabitLogEntity(date: date(daysAgo: 2, from: baseDate), progress: 1)
            ]
        )
        
        #expect(habit.currentStreak(at: baseDate, calendar: calendar) == 0)
    }
    
    @Test("Completion percentage calculation for 7 days")
    func completionPercentageCalculatesAccurately() {
        let baseDate = Date()
        let habit = HabitEntity(
            name: "Escribir",
            frequency: .daily,
            type: .simple,
            logs: [
                HabitLogEntity(date: date(daysAgo: 0, from: baseDate), progress: 1),
                HabitLogEntity(date: date(daysAgo: 1, from: baseDate), progress: 1),
                HabitLogEntity(date: date(daysAgo: 2, from: baseDate), progress: 1)
            ]
        )
        
        let percentage = habit.completionPercentage(forLast: 7, endingAt: baseDate, calendar: calendar)
        let expected = (3.0 / 7.0) * 100.0
        #expect(abs(percentage - expected) < 0.01)
    }
}
