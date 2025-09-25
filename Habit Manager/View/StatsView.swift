import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    @State private var selectedPeriod: StatsPeriod = .week
    
    private var habitsWithStreaks: [Habit] {
        habits.filter { $0.currentStreak > 0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if habits.isEmpty {
                        ContentUnavailableView("Sin Hábitos", systemImage: "chart.bar.xaxis", description: Text("Aún no has creado ningún hábito para ver tus estadísticas."))
                            .padding(.top, 50)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Resumen de Cumplimiento")
                                    .font(.title2.bold())
                                
                                Picker("Periodo", selection: $selectedPeriod) {
                                    ForEach(StatsPeriod.allCases) { period in
                                        Text(period.rawValue).tag(period)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(habits) { habit in
                                    VStack(alignment: .leading) {
                                        let percentage = habit.completionPercentage(forLast: selectedPeriod.dayCount)
                                        
                                        Text(habit.name + "   " + "\(Int(percentage))%")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                        
                                        Gauge(value: percentage, in: 0...100) { }
                                            .tint(percentage >= 80 ? .green : (percentage >= 50 ? .orange : .red))
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.quinary)
                            .padding(.horizontal)
                        }

                    }
                    
                    if !habitsWithStreaks.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Tus Rachas Actuales")
                                .font(.title2.bold())
                                .padding([.horizontal, .top])
                            
                            Chart(habitsWithStreaks) { habit in
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
                                        .font(.headline)
                                }
                            }
                            .frame(minHeight: CGFloat(habits.count) * 50)
                            .padding()
                            .background(in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Estadísticas")
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}


enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "Últimos 7 días"
    case month = "Últimos 30 días"
    
    var id: String { self.rawValue }
    
    var dayCount: Int {
        switch self {
        case .week:
            return 7
        case .month:
            return 30
        }
    }
}
