import ActivityKit
import SwiftUI
import WidgetKit

struct HabitActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HabitActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            HabitActivityLockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.habitName)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            
                            Text("Racha: \(context.attributes.habitStreak) días")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.leading, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(.blue)
                        
                        Text("de \(context.attributes.targetMinutes) min")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label(context.state.statusMessage, systemImage: "sparkles")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("Enfoque activo")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.blue.opacity(0.2)))
                            .foregroundStyle(.blue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                }
            } compactLeading: {
                HStack(spacing: 3) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text(context.attributes.habitName)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                }
                .padding(.leading, 4)
            } compactTrailing: {
                Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundStyle(.blue)
                    .frame(width: 44)
                    .padding(.trailing, 4)
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}

// MARK: - Lock Screen Banner View

private struct HabitActivityLockScreenView: View {
    let context: ActivityViewContext<HabitActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label {
                    Text(context.attributes.habitName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "flame")
                        .font(.caption2)
                    Text("\(context.attributes.habitStreak)d")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.orange.opacity(0.25)))
                .foregroundStyle(.orange)
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TIEMPO RESTANTE")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text("OBJETIVO")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text("\(context.attributes.targetMinutes) min")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            
            HStack {
                Label(context.state.statusMessage, systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("Mantén la concentración")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
