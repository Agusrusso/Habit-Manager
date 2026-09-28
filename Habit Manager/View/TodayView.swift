import SwiftUI

struct TodayView: View {
    @State var viewModel: TodayViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.habits.isEmpty {
                    ProgressView()
                } else if viewModel.habits.isEmpty {
                    ContentUnavailableView(
                        "No hay hábitos para hoy",
                        systemImage: "sun.max",
                        description: Text("¡Disfruta de tu día libre o añade nuevos hábitos!")
                    )
                } else {
                    List(viewModel.habits) { habit in
                        if habit.type == .quantitative {
                            QuantitativeHabitRow(
                                habit: habit,
                                onProgressChange: { newProgress in
                                    Task {
                                        await viewModel.setProgress(for: habit, progress: newProgress)
                                    }
                                }
                            )
                        } else {
                            SimpleHabitRow(
                                habit: habit,
                                onToggle: {
                                    Task {
                                        await viewModel.toggleCompletion(for: habit)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Hoy")
            .task {
                await viewModel.loadHabits()
            }
            .refreshable {
                await viewModel.loadHabits()
            }
        }
    }
}

struct SimpleHabitRow: View {
    let habit: HabitEntity
    let onToggle: () -> Void
    
    private var isCompletedToday: Bool {
        habit.isCompleted(on: .now)
    }
    
    var body: some View {
        HStack {
            Text(habit.name)
                .font(.headline)
            Spacer()
            Button(action: onToggle) {
                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompletedToday ? .green : .gray)
            }
            .buttonStyle(.plain)
        }
    }
}

struct QuantitativeHabitRow: View {
    let habit: HabitEntity
    let onProgressChange: (Int) -> Void
    
    private var isCompletedToday: Bool {
        habit.isCompleted(on: .now)
    }
    
    private var todaysProgress: Int {
        habit.progress(on: .now)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(habit.name)
                    .font(.headline)
                
                Spacer()
                
                if isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            HStack {
                Text("\(todaysProgress) / \(habit.goal) \(habit.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Stepper(
                    "Progreso",
                    value: Binding<Int>(
                        get: { todaysProgress },
                        set: { onProgressChange($0) }
                    ),
                    in: 0...999
                )
                .labelsHidden()
            }
        }
        .padding(.vertical, 4)
    }
}
