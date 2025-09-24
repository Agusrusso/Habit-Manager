import SwiftUI
import SwiftData

struct HabitListView: View {
    @Query(sort: \Habit.creationDate, order: .reverse) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    
    @State private var isShowingAddView = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    NavigationLink(destination: AddEditHabitView(habit: habit)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.name.isEmpty ? "Hábito sin nombre" : habit.name)
                                    .font(.headline)
                                
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
                        }
                    }
                }
                .onDelete(perform: deleteHabit)
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
                AddEditHabitView(habit: nil)
            }
        }
    }

    private func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            NotificationManager.shared.cancelNotification(for: habit)
            modelContext.delete(habit)
        }
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: Habit.self, inMemory: true)
}
