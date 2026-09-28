import SwiftUI
import WidgetKit
import AppIntents

public struct HabitWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    public let snapshot: HabitWidgetSnapshot
    
    public init(snapshot: HabitWidgetSnapshot) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        switch family {
        case .systemSmall:
            SmallHabitWidgetView(snapshot: snapshot)
        case .systemMedium:
            MediumHabitWidgetView(snapshot: snapshot)
        case .accessoryCircular:
            CircularAccessoryWidgetView(snapshot: snapshot)
        case .accessoryRectangular:
            RectangularAccessoryWidgetView(snapshot: snapshot)
        case .accessoryInline:
            InlineAccessoryWidgetView(snapshot: snapshot)
        default:
            MediumHabitWidgetView(snapshot: snapshot)
        }
    }
}

// MARK: - System Small View
public struct SmallHabitWidgetView: View {
    public let snapshot: HabitWidgetSnapshot
    
    public init(snapshot: HabitWidgetSnapshot) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Hoy")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                if snapshot.highestStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(snapshot.highestStreak)")
                            .font(.caption.bold())
                    }
                }
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(1.0, snapshot.completionPercentage / 100.0)))
                    .stroke(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(Int(snapshot.completionPercentage))%")
                        .font(.title3.bold())
                    Text("\(snapshot.completedCount)/\(snapshot.totalCount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 70, height: 70)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            Text(snapshot.completedCount == snapshot.totalCount && snapshot.totalCount > 0 ? "¡Todo al día!" : "\(snapshot.totalCount - snapshot.completedCount) pendientes")
                .font(.caption.bold())
                .foregroundStyle(snapshot.completedCount == snapshot.totalCount && snapshot.totalCount > 0 ? .green : .secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
    }
}

// MARK: - System Medium View (Interactive List)
public struct MediumHabitWidgetView: View {
    public let snapshot: HabitWidgetSnapshot
    
    public init(snapshot: HabitWidgetSnapshot) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Mis Hábitos de Hoy")
                    .font(.headline)
                Spacer()
                if snapshot.highestStreak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(snapshot.highestStreak) días")
                            .font(.caption.bold())
                    }
                }
                Text("•")
                    .foregroundStyle(.secondary)
                Text("\(snapshot.completedCount)/\(snapshot.totalCount)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 2)
            
            if snapshot.habits.isEmpty {
                VStack(spacing: 6) {
                    Spacer()
                    Image(systemName: "sun.max.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text("No hay hábitos programados para hoy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 6) {
                    ForEach(snapshot.habits.prefix(3)) { habit in
                        HStack(spacing: 10) {
                            Button(intent: ToggleHabitIntent(habitId: habit.id)) {
                                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(habit.isCompleted ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.name)
                                    .font(.subheadline)
                                    .fontWeight(habit.isCompleted ? .regular : .semibold)
                                    .strikethrough(habit.isCompleted)
                                    .foregroundStyle(habit.isCompleted ? .secondary : .primary)
                                    .lineLimit(1)
                                
                                if habit.isQuantitative {
                                    Text("\(habit.progress)/\(habit.goal) \(habit.unit)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if habit.currentStreak > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                    Text("\(habit.currentStreak)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                        
                        if habit.id != snapshot.habits.prefix(3).last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Lock Screen Accessories
public struct CircularAccessoryWidgetView: View {
    public let snapshot: HabitWidgetSnapshot
    
    public init(snapshot: HabitWidgetSnapshot) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        Gauge(value: snapshot.completionPercentage, in: 0...100) {
            Image(systemName: "checklist")
        } currentValueLabel: {
            Text("\(Int(snapshot.completionPercentage))%")
                .font(.caption2.bold())
        }
        .gaugeStyle(.accessoryCircular)
    }
}

public struct RectangularAccessoryWidgetView: View {
    public let snapshot: HabitWidgetSnapshot
    
    public init(snapshot: HabitWidgetSnapshot) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "checklist")
                Text("Hábitos")
                    .font(.caption.bold())
                Spacer()
                Text("\(snapshot.completedCount)/\(snapshot.totalCount)")
                    .font(.caption2)
            }
            
            if let pending = snapshot.habits.first(where: { !$0.isCompleted }) {
                Text(pending.name)
                    .font(.caption2)
                    .lineLimit(1)
            } else if snapshot.totalCount > 0 {
                Text("¡Todos completados!")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("Sin hábitos hoy")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: snapshot.completionPercentage, total: 100)
        }
    }
}

public struct InlineAccessoryWidgetView: View {
    public let snapshot: HabitWidgetSnapshot
    
    public init(snapshot: HabitWidgetSnapshot) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        Text("🔥 \(snapshot.highestStreak)d • \(snapshot.completedCount)/\(snapshot.totalCount) hábitos")
    }
}
