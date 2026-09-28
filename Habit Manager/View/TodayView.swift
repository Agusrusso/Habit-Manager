import SwiftUI

struct TodayView: View {
    @State var viewModel: TodayViewModel
    @State private var selectedHabitForFocus: HabitEntity? = nil
    
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
                        let isFocusActive = viewModel.activeFocusHabitIds.contains(habit.id)
                        
                        if habit.type == .quantitative {
                            QuantitativeHabitRow(
                                habit: habit,
                                isFocusActive: isFocusActive,
                                onProgressChange: { newProgress in
                                    Task {
                                        await viewModel.setProgress(for: habit, progress: newProgress)
                                    }
                                },
                                onOpenFocus: {
                                    selectedHabitForFocus = habit
                                }
                            )
                        } else {
                            SimpleHabitRow(
                                habit: habit,
                                isFocusActive: isFocusActive,
                                onToggle: {
                                    Task {
                                        await viewModel.toggleCompletion(for: habit)
                                    }
                                },
                                onOpenFocus: {
                                    selectedHabitForFocus = habit
                                }
                            )
                        }
                    }
                    .accessibilityIdentifier("today_habits_list")
                }
            }
            .navigationTitle("Hoy")
            .sheet(item: $selectedHabitForFocus) { habit in
                FocusSessionSheet(habit: habit, viewModel: viewModel)
            }
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
                await viewModel.checkActiveFocusSessions()
            }
            .onAppear {
                Task {
                    await viewModel.loadHabits()
                    await viewModel.checkActiveFocusSessions()
                }
            }
            .refreshable {
                await viewModel.loadHabits()
                await viewModel.checkActiveFocusSessions()
            }
        }
    }
}

struct SimpleHabitRow: View {
    let habit: HabitEntity
    let isFocusActive: Bool
    let onToggle: () -> Void
    let onOpenFocus: () -> Void
    
    private var isCompletedToday: Bool {
        habit.isCompleted(on: .now)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onOpenFocus) {
                Image(systemName: isFocusActive ? "timer.circle.fill" : "timer")
                    .font(.title3)
                    .foregroundStyle(isFocusActive ? .blue : .secondary.opacity(0.7))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("habit_focus_button_\(habit.name)")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.headline)
                    .accessibilityIdentifier("today_habit_title_\(habit.name)")
                
                if isFocusActive {
                    Text("Enfoque activo")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }
            
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
    let isFocusActive: Bool
    let onProgressChange: (Int) -> Void
    let onOpenFocus: () -> Void
    
    private var isCompletedToday: Bool {
        habit.isCompleted(on: .now)
    }
    
    private var todaysProgress: Int {
        habit.progress(on: .now)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Button(action: onOpenFocus) {
                    Image(systemName: isFocusActive ? "timer.circle.fill" : "timer")
                        .font(.title3)
                        .foregroundStyle(isFocusActive ? .blue : .secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("habit_focus_button_\(habit.name)")
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.headline)
                        .accessibilityIdentifier("today_habit_title_\(habit.name)")
                    
                    if isFocusActive {
                        Text("Enfoque activo")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
                
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

