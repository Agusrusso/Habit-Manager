import SwiftUI

struct DayOfWeekSelector: View {
    @Binding var selectedDays: Set<Weekday>
    
    private let allDays = Weekday.allCases.sorted { $0.rawValue < $1.rawValue }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(allDays.indices, id: \.self) { index in
                let day = allDays[index]
                Button(action: {
                    toggleDaySelection(day)
                }) {
                    Text(day.initial)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedDays.contains(day) ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private func toggleDaySelection(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}
