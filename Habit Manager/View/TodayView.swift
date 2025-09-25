import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(sort: \Habit.creationDate, order: .reverse) private var allHabits: [Habit]
    @Environment(\.modelContext) private var modelContext
    
    @State private var todaysHabits: [Habit] = []
    
    var body: some View {
        NavigationStack {
            List(todaysHabits) { habit in
                if habit.type == .quantitative {
                    QuantitativeHabitRow(habit: habit)
                } else {
                    SimpleHabitRow(habit: habit)
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
}

struct SimpleHabitRow: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack {
            Text(habit.name)
                .font(.headline)
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
    
    private func toggleCompletion(for habit: Habit) {
        let today = Calendar.current.startOfDay(for: .now)
        if let log = habit.todaysLog {
            modelContext.delete(log)
        } else {
            let newLog = HabitLog(date: today, progress: 1)
            habit.logs.append(newLog)
        }
    }
}

struct QuantitativeHabitRow: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        let progressBinding = Binding<Int>(
            get: {
                habit.todaysProgress
            },
            set: { newProgress in
                let today = Calendar.current.startOfDay(for: .now)
                if let log = habit.todaysLog {
                    log.progress = newProgress
                    if newProgress == 0 {
                        modelContext.delete(log)
                    }
                } else if newProgress > 0 {
                    let newLog = HabitLog(date: today, progress: newProgress)
                    habit.logs.append(newLog)
                }
            }
        )
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(habit.name)
                    .font(.headline)
                
                Spacer()
                
                if habit.isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            HStack {
                Text("\(habit.todaysProgress) / \(habit.goal) \(habit.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Stepper("Progreso", value: progressBinding, in: 0...999)
                    .labelsHidden()
            }
        }
        .padding(.vertical, 4)
    }
}
