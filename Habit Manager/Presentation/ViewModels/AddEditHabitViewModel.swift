import Foundation
import Observation

@MainActor
@Observable
public final class AddEditHabitViewModel {
    private let habitToEdit: HabitEntity?
    private let saveHabitUseCase: SaveHabitUseCaseProtocol
    private let deleteHabitUseCase: DeleteHabitUseCaseProtocol?
    
    public var name: String
    public var habitDescription: String
    public var frequencyCase: HabitFrequency.Case
    public var selectedDays: Set<Weekday>
    public var reminderEnabled: Bool
    public var reminderTime: Date
    public var type: HabitType
    public var goal: Int
    public var unit: String
    
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    public var isEditing: Bool {
        habitToEdit != nil
    }
    
    public var title: String {
        isEditing ? "Editar Hábito" : "Nuevo Hábito"
    }
    
    public var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        (frequencyCase == .weekly && selectedDays.isEmpty)
    }
    
    public init(
        habitToEdit: HabitEntity? = nil,
        saveHabitUseCase: SaveHabitUseCaseProtocol,
        deleteHabitUseCase: DeleteHabitUseCaseProtocol? = nil
    ) {
        self.habitToEdit = habitToEdit
        self.saveHabitUseCase = saveHabitUseCase
        self.deleteHabitUseCase = deleteHabitUseCase
        
        if let habit = habitToEdit {
            self.name = habit.name
            self.habitDescription = habit.habitDescription
            self.frequencyCase = habit.frequency.case
            switch habit.frequency {
            case .daily:
                self.selectedDays = []
            case .weekly(let days):
                self.selectedDays = days
            }
            self.reminderEnabled = habit.reminderEnabled
            self.reminderTime = habit.reminderTime
            self.type = habit.type
            self.goal = habit.goal
            self.unit = habit.unit
        } else {
            self.name = ""
            self.habitDescription = ""
            self.frequencyCase = .daily
            self.selectedDays = []
            self.reminderEnabled = false
            self.reminderTime = Date()
            self.type = .simple
            self.goal = 1
            self.unit = ""
        }
    }
    
    public func save() async -> Bool {
        guard !isSaveDisabled else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let frequency: HabitFrequency
        switch frequencyCase {
        case .daily:
            frequency = .daily
        case .weekly:
            frequency = .weekly(selectedDays)
        }
        
        let habit = HabitEntity(
            id: habitToEdit?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: habitDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            frequency: frequency,
            creationDate: habitToEdit?.creationDate ?? Date(),
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime,
            type: type,
            goal: goal,
            unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
            logs: habitToEdit?.logs ?? []
        )
        
        do {
            try await saveHabitUseCase.execute(habit)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    public func delete() async -> Bool {
        guard let habitToEdit, let deleteHabitUseCase else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await deleteHabitUseCase.execute(habitId: habitToEdit.id)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
