import SwiftUI
import Charts

struct StatsView: View {
    @State var viewModel: StatsViewModel
    @State private var selectedPeriod: StatsPeriod = .week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if viewModel.isLoading && !viewModel.hasHabits {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else if !viewModel.hasHabits {
                        ContentUnavailableView(
                            "Sin Hábitos",
                            systemImage: "chart.bar.xaxis",
                            description: Text("Aún no has creado ningún hábito para ver tus estadísticas.")
                        )
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
                                ForEach(viewModel.stats) { stat in
                                    VStack(alignment: .leading) {
                                        let percentage = selectedPeriod == .week ? stat.weeklyCompletionPercentage : stat.monthlyCompletionPercentage
                                        
                                        Text("\(stat.habitName)   \(Int(percentage))%")
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

                        if viewModel.hasStreaks {
                            VStack(alignment: .leading) {
                                Text("Tus Rachas Actuales")
                                    .font(.title2.bold())
                                    .padding([.horizontal, .top])
                                
                                Chart(viewModel.streaksForChart) { stat in
                                    BarMark(
                                        x: .value("Racha", stat.streak),
                                        y: .value("Hábito", stat.habitName)
                                    )
                                    .foregroundStyle(by: .value("Hábito", stat.habitName))
                                    .annotation(position: .trailing) {
                                        Text("\(stat.streak)")
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
                                .frame(minHeight: CGFloat(viewModel.streaksForChart.count) * 50)
                                .padding()
                                .background(in: RoundedRectangle(cornerRadius: 10))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Estadísticas")
            .background(Color(uiColor: .systemGroupedBackground))
            .task {
                await viewModel.loadStats()
            }
            .refreshable {
                await viewModel.loadStats()
            }
        }
    }
}

enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "Últimos 7 días"
    case month = "Últimos 30 días"
    
    var id: String { self.rawValue }
}
