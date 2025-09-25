import SwiftUI

struct AddEditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var habit: Habit?
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var frequency: HabitFrequency = .daily
    @State private var weeklyDayCache: Set<Weekday> = []
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Date()
    @State private var habitType: HabitType = .simple
    @State private var goal: String = "1"
    @State private var unit: String = ""

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
                
                Section("Tipo de Hábito") {
                    Picker("Tipo", selection: $habitType) {
                        Text("Simple").tag(HabitType.simple)
                        Text("Cuantitativo").tag(HabitType.quantitative)
                    }
                    .pickerStyle(.segmented)
                    
                    if habitType == .quantitative {
                        TextField("Meta (ej: 30)", text: $goal)
                            .keyboardType(.numberPad)
                        TextField("Unidad (ej: minutos)", text: $unit)
                    }
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
                
                Section("Recordatorio") {
                        Toggle("Activar recordatorio", isOn: $reminderEnabled)
                        
                        if reminderEnabled {
                            DatePicker("Hora", selection: $reminderTime, displayedComponents: .hourAndMinute)
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
            self.reminderEnabled = habit.reminderEnabled
            self.reminderTime = habit.reminderTime
            self.habitType = habit.type
            self.goal = String(habit.goal)
            self.unit = habit.unit
            
            if case .weekly(let days) = habit.frequency {
                self.weeklyDayCache = days
            }
        }
    }
    
    private func saveHabit() {
        let habitToSave: Habit
        let goalValue = Int(goal) ?? 1
        
        if let habit = habit {
            habit.name = name
            habit.habitDescription = description
            habit.frequency = frequency
            habit.reminderEnabled = reminderEnabled
            habit.reminderTime = reminderTime
            habit.type = habitType
            habit.goal = goalValue
            habit.unit = unit
            habitToSave = habit
        } else {
            let newHabit = Habit(name: name, description: description, frequency: frequency, reminderEnabled: reminderEnabled, reminderTime: reminderTime, type: habitType, goal: goalValue, unit: unit)
            modelContext.insert(newHabit)
            habitToSave = newHabit
        }
        NotificationManager.shared.scheduleNotification(for: habitToSave)
        dismiss()
    }
}
