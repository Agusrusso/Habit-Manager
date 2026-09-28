import WidgetKit
import SwiftUI

public struct HabitTimelineEntry: TimelineEntry {
    public let date: Date
    public let snapshot: HabitWidgetSnapshot
    
    public init(date: Date, snapshot: HabitWidgetSnapshot) {
        self.date = date
        self.snapshot = snapshot
    }
}

public struct HabitTimelineProvider: TimelineProvider {
    public init() {}
    
    public func placeholder(in context: Context) -> HabitTimelineEntry {
        HabitTimelineEntry(date: .now, snapshot: .previewSample)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (HabitTimelineEntry) -> Void) {
        if context.isPreview {
            completion(HabitTimelineEntry(date: .now, snapshot: .previewSample))
        } else {
            let current = SharedHabitStore.shared.loadSnapshot()
            completion(HabitTimelineEntry(date: .now, snapshot: current))
        }
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<HabitTimelineEntry>) -> Void) {
        let current = SharedHabitStore.shared.loadSnapshot()
        let entry = HabitTimelineEntry(date: .now, snapshot: current)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

public struct HabitWidget: Widget {
    public static let kind: String = "HabitWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HabitTimelineProvider()) { entry in
            HabitWidgetEntryView(snapshot: entry.snapshot)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Mis Hábitos")
        .description("Consulta y marca tus hábitos diarios directamente desde tu pantalla de inicio o bloqueo.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
