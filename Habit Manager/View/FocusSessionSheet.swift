import SwiftUI

struct FocusSessionSheet: View {
    let habit: HabitEntity
    let viewModel: TodayViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMinutes: Int = 25
    @State private var isStarting: Bool = false
    
    private let durations = [5, 10, 15, 25, 45, 60]
    
    private var isCurrentlyActive: Bool {
        viewModel.activeFocusHabitIds.contains(habit.id)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header card
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: isCurrentlyActive ? "timer.circle.fill" : "timer")
                            .font(.system(size: 38))
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 8)
                    
                    Text(habit.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(habit.currentStreak()) días de racha")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                if isCurrentlyActive {
                    // Active session UI
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.blue)
                            Text("Sesión de enfoque en curso")
                                .font(.headline)
                                .foregroundStyle(.blue)
                        }
                        
                        Text("La Live Activity está activa en tu Dynamic Island y Pantalla de Bloqueo.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Button {
                                Task {
                                    await viewModel.endFocusSession(for: habit, markCompleted: true)
                                    dismiss()
                                }
                            } label: {
                                Label("Completar Hábito y Finalizar", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.endFocusSession(for: habit, markCompleted: false)
                                    dismiss()
                                }
                            } label: {
                                Text("Detener sesión sin completar")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    )
                } else {
                    // New session picker
                    VStack(alignment: .leading, spacing: 14) {
                        Text("DURACIÓN DEL ENFOQUE")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(durations, id: \.self) { mins in
                                Button {
                                    selectedMinutes = mins
                                } label: {
                                    VStack(spacing: 4) {
                                        Text("\(mins)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("min")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedMinutes == mins ? Color.blue.opacity(0.15) : Color(uiColor: .secondarySystemGroupedBackground))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedMinutes == mins ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .foregroundStyle(selectedMinutes == mins ? Color.blue : Color.primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.gen3")
                                .foregroundStyle(.secondary)
                            Text("Se mostrará en vivo en Dynamic Island y Pantalla de Bloqueo.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                    
                    Button {
                        isStarting = true
                        Task {
                            await viewModel.startFocusSession(for: habit, durationMinutes: selectedMinutes)
                            isStarting = false
                            dismiss()
                        }
                    } label: {
                        HStack {
                            if isStarting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "play.fill")
                                Text("Comenzar Enfoque (\(selectedMinutes) min)")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isStarting)
                    .accessibilityIdentifier("start_focus_session_button")
                }
            }
            .padding()
            .navigationTitle("Sesión de Enfoque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
