import SwiftUI
import SwiftData

struct TodayView: View {
    @Query private var allHabits: [Habit]
    @Environment(\.modelContext) private var modelContext
    
    @State private var todaysHabits: [Habit] = []
    
    var body: some View {
        NavigationStack {
            List(todaysHabits) { habit in
                HStack {
                    VStack(alignment: .leading) {
                        Text(habit.name)
                            .font(.headline)
                        Text(habit.frequency.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        toggleCompletion(for: habit)
                    }) {
                        Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(habit.isCompletedToday ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Hoy")
            .onAppear(perform: filterTodaysHabits)
            .onChange(of: allHabits, initial: true) { _, _ in
                filterTodaysHabits()
            }
        }
    }
    
    private func filterTodaysHabits() {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: .now)
        
        todaysHabits = allHabits.filter { habit in
            switch habit.frequency {
            case .daily:
                return true
            case .weekly(let weekdays):
                return weekdays.contains { $0.rawValue == todayWeekday }
            }
        }
    }
    
    private func toggleCompletion(for habit: Habit) {
        let today = Calendar.current.startOfDay(for: .now)
        
        if let log = habit.logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Si ya existe un log para hoy, lo eliminamos (desmarcar)
            modelContext.delete(log)
        } else {
            // Si no existe, creamos un nuevo log (marcar)
            let newLog = HabitLog(date: today)
            newLog.habit = habit
            modelContext.insert(newLog)
        }
    }
}
