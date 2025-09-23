import SwiftUI

struct AddEditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var habit: Habit?
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var frequency: HabitFrequency = .daily
    @State private var weeklyDayCache: Set<Weekday> = []

    var body: some View {
        let frequencyCaseBinding = Binding<HabitFrequency.Case>(
            get: {
                self.frequency.case
            },
            set: { newCase in
                switch newCase {
                case .daily:
                    if case .weekly(let days) = self.frequency {
                        self.weeklyDayCache = days
                    }
                    self.frequency = .daily
                case .weekly:
                    self.frequency = .weekly(self.weeklyDayCache)
                }
            }
        )

        let weeklySelectionBinding = Binding<Set<Weekday>>(
            get: {
                if case .weekly(let days) = self.frequency {
                    return days
                }
                return []
            },
            set: { newDays in
                self.frequency = .weekly(newDays)
                self.weeklyDayCache = newDays
            }
        )
        
        NavigationStack {
            Form {
                Section(header: Text("Detalles del Hábito")) {
                    TextField("Nombre (ej: Leer 30 minutos)", text: $name)
                    TextField("Descripción (opcional)", text: $description)
                }
                
                Section(header: Text("Frecuencia")) {
                    Picker("Tipo", selection: frequencyCaseBinding) {
                        Text("Diaria").tag(HabitFrequency.Case.daily)
                        Text("Semanal").tag(HabitFrequency.Case.weekly)
                    }
                    .pickerStyle(.segmented)
                    
                    if self.frequency.case == .weekly {
                        DayOfWeekSelector(selectedDays: weeklySelectionBinding)
                    }
                }
            }
            .navigationTitle(habit == nil ? "Nuevo Hábito" : "Editar Hábito")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Guardar") { saveHabit() }.disabled(name.isEmpty) }
            }
        }
        .onAppear(perform: loadHabitData)
    }
    
    private func loadHabitData() {
        if let habit = habit {
            self.name = habit.name
            self.description = habit.habitDescription
            self.frequency = habit.frequency
            
            if case .weekly(let days) = habit.frequency {
                self.weeklyDayCache = days
            }
        }
    }
    
    private func saveHabit() {
        if let habit = habit {
            habit.name = name
            habit.habitDescription = description
            habit.frequency = frequency
        } else {
            let newHabit = Habit(name: name, description: description, frequency: frequency)
            modelContext.insert(newHabit)
        }
        dismiss()
    }
}
