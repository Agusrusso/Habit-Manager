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
                    .accessibilityIdentifier("today_habits_list")
                }
            }
            .navigationTitle("Hoy")
            .overlay(alignment: .top) {
                if viewModel.showAchievementToast, let achievement = viewModel.latestUnlockedAchievement {
                    HStack(spacing: 12) {
                        Image(systemName: achievement.iconName)
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("¡Nuevo Logro Desbloqueado!")
                                .font(.caption.bold())
                                .foregroundStyle(.orange)
                            Text("\(achievement.title) (+\(achievement.xpReward) XP)")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewModel.dismissAchievementToast()
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation {
                                viewModel.dismissAchievementToast()
                            }
                        }
                    }
                }
            }
            .animation(.spring(), value: viewModel.showAchievementToast)
            .task {
                await viewModel.loadHabits()
            }
            .onAppear {
                Task {
                    await viewModel.loadHabits()
                }
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
                .accessibilityIdentifier("today_habit_title_\(habit.name)")
            Spacer()
            Button(action: onToggle) {
                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isCompletedToday ? .green : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("habit_completion_toggle_\(habit.name)")
            .accessibilityValue(isCompletedToday ? "completed" : "incomplete")
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
                    .accessibilityIdentifier("today_habit_title_\(habit.name)")
                
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
                .accessibilityIdentifier("habit_progress_stepper_\(habit.name)")
            }
        }
        .padding(.vertical, 4)
    }
}
