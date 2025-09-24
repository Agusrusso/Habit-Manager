import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Tus Rachas Actuales")
                        .font(.title2.bold())
                        .padding([.horizontal, .top])
                    
                    if habits.isEmpty {
                        ContentUnavailableView("Sin Hábitos", systemImage: "chart.bar.xaxis", description: Text("Aún no has creado ningún hábito para ver tus estadísticas."))
                            .padding(.top, 50)
                    } else {
                        Chart(habits) { habit in
                            BarMark(
                                x: .value("Racha", habit.currentStreak),
                                y: .value("Hábito", habit.name)
                            )
                            .foregroundStyle(by: .value("Hábito", habit.name))
                            .annotation(position: .trailing) {
                                Text("\(habit.currentStreak)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .chartLegend(.hidden)
                        .chartXAxis(.hidden)
                        .chartYAxis {
                            AxisMarks { _ in
                                AxisValueLabel()
                                    .font(.subheadline)
                            }
                        }
                        .frame(minHeight: CGFloat(habits.count) * 50)
                        .padding()
                        .background(in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Estadísticas")
        }
    }
}
