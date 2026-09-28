import SwiftUI

struct HabitListView: View {
    @State var viewModel: HabitListViewModel
    @Environment(\.dependencyContainer) private var dependencyContainer
    
    @State private var habitToEdit: HabitEntity? = nil
    @State private var isShowingAddView: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.habits.isEmpty {
                    ProgressView()
                } else if viewModel.habits.isEmpty {
                    ContentUnavailableView(
                        "Sin Hábitos",
                        systemImage: "list.bullet",
                        description: Text("Aún no tienes hábitos registrados. Toca '+' para crear uno.")
                    )
                } else {
                    List {
                        ForEach(viewModel.habits) { habit in
                            Button(action: {
                                habitToEdit = habit
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit.name.isEmpty ? "Hábito sin nombre" : habit.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        
                                        Text(habit.frequency.description)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .fontWeight(.semibold)
                                        
                                        if !habit.habitDescription.isEmpty {
                                            Text(habit.habitDescription)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            Task {
                                await viewModel.deleteHabits(at: offsets)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mis Hábitos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingAddView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddView) {
                if let dependencyContainer {
                    AddEditHabitView(
                        viewModel: dependencyContainer.makeAddEditHabitViewModel(),
                        onSaved: {
                            Task { await viewModel.loadHabits() }
                        }
                    )
                }
            }
            .sheet(item: $habitToEdit) { habit in
                if let dependencyContainer {
                    AddEditHabitView(
                        viewModel: dependencyContainer.makeAddEditHabitViewModel(habitToEdit: habit),
                        onSaved: {
                            Task { await viewModel.loadHabits() }
                        }
                    )
                }
            }
            .task {
                await viewModel.loadHabits()
            }
            .refreshable {
                await viewModel.loadHabits()
            }
        }
    }
}
