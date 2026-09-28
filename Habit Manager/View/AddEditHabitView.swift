import SwiftUI

struct AddEditHabitView: View {
    @State var viewModel: AddEditHabitViewModel
    @Environment(\.dismiss) private var dismiss
    var onSaved: (() -> Void)? = nil
    
    var body: some View {
        let frequencyCaseBinding = Binding<HabitFrequency.Case>(
            get: { viewModel.frequencyCase },
            set: { viewModel.frequencyCase = $0 }
        )
        
        let weeklySelectionBinding = Binding<Set<Weekday>>(
            get: { viewModel.selectedDays },
            set: { viewModel.selectedDays = $0 }
        )
        
        NavigationStack {
            Form {
                Section(header: Text("Detalles del Hábito")) {
                    TextField("Nombre (ej: Leer 30 minutos)", text: $viewModel.name)
                    TextField("Descripción (opcional)", text: $viewModel.habitDescription)
                }
                
                Section("Tipo de Hábito") {
                    Picker("Tipo", selection: $viewModel.type) {
                        Text("Simple").tag(HabitType.simple)
                        Text("Cuantitativo").tag(HabitType.quantitative)
                    }
                    .pickerStyle(.segmented)
                    
                    if viewModel.type == .quantitative {
                        TextField(
                            "Meta (ej: 30)",
                            value: $viewModel.goal,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        TextField("Unidad (ej: minutos)", text: $viewModel.unit)
                    }
                }
                
                Section(header: Text("Frecuencia")) {
                    Picker("Tipo", selection: frequencyCaseBinding) {
                        Text("Diaria").tag(HabitFrequency.Case.daily)
                        Text("Semanal").tag(HabitFrequency.Case.weekly)
                    }
                    .pickerStyle(.segmented)
                    
                    if viewModel.frequencyCase == .weekly {
                        DayOfWeekSelector(selectedDays: weeklySelectionBinding)
                    }
                }
                
                Section("Recordatorio") {
                    Toggle("Activar recordatorio", isOn: $viewModel.reminderEnabled)
                    
                    if viewModel.reminderEnabled {
                        DatePicker("Hora", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task {
                            let success = await viewModel.save()
                            if success {
                                onSaved?()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaveDisabled || viewModel.isLoading)
                }
            }
        }
    }
}
