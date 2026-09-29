import Foundation
import Testing
@testable import Habit_Manager

@Suite("AddEditHabitViewModel Tests")
struct AddEditHabitViewModelTests {
    
    @Test("AddEditHabitViewModel validation rules")
    @MainActor
    func validationRules() {
        let repository = MockHabitRepository()
        let notificationService = MockNotificationService()
        let saveUseCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        
        let vmEmpty = AddEditHabitViewModel(saveHabitUseCase: saveUseCase)
        vmEmpty.name = ""
        #expect(vmEmpty.isSaveDisabled == true)
        
        vmEmpty.name = "Ejercicio"
        vmEmpty.frequencyCase = .weekly
        vmEmpty.selectedDays = []
        #expect(vmEmpty.isSaveDisabled == true)
        
        vmEmpty.selectedDays = [.monday]
        #expect(vmEmpty.isSaveDisabled == false)
        
        vmEmpty.frequencyCase = .daily
        #expect(vmEmpty.isSaveDisabled == false)
    }
    
    @Test("AddEditHabitViewModel saves new habit successfully")
    @MainActor
    func saveNewHabit() async {
        let repository = MockHabitRepository()
        let notificationService = MockNotificationService()
        let saveUseCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        
        let vm = AddEditHabitViewModel(saveHabitUseCase: saveUseCase)
        vm.name = "Leer libro"
        vm.habitDescription = "20 mins diarios"
        vm.frequencyCase = .daily
        vm.type = .simple
        
        let success = await vm.save()
        #expect(success == true)
        
        let savedHabits = try! await repository.getHabits()
        #expect(savedHabits.count == 1)
        #expect(savedHabits.first?.name == "Leer libro")
    }
    
    @Test("AddEditHabitViewModel edits existing habit")
    @MainActor
    func editExistingHabit() async {
        let habit = HabitEntity(name: "Original", frequency: .daily)
        let repository = MockHabitRepository(initialHabits: [habit])
        let notificationService = MockNotificationService()
        let saveUseCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        
        let vm = AddEditHabitViewModel(habitToEdit: habit, saveHabitUseCase: saveUseCase)
        #expect(vm.isEditing == true)
        #expect(vm.name == "Original")
        
        vm.name = "Modificado"
        let success = await vm.save()
        #expect(success == true)
        
        let fetched = try! await repository.getHabit(byId: habit.id)
        #expect(fetched?.name == "Modificado")
    }
    
    @Test("AddEditHabitViewModel deletes existing habit")
    @MainActor
    func deleteExistingHabit() async {
        let habit = HabitEntity(name: "Para Eliminar", frequency: .daily)
        let repository = MockHabitRepository(initialHabits: [habit])
        let notificationService = MockNotificationService()
        let saveUseCase = SaveHabitUseCase(repository: repository, notificationService: notificationService)
        let deleteUseCase = DeleteHabitUseCase(repository: repository, notificationService: notificationService)
        
        let vm = AddEditHabitViewModel(
            habitToEdit: habit,
            saveHabitUseCase: saveUseCase,
            deleteHabitUseCase: deleteUseCase
        )
        
        let success = await vm.delete()
        #expect(success == true)
        
        let savedHabits = try! await repository.getHabits()
        #expect(savedHabits.isEmpty)
    }
}
