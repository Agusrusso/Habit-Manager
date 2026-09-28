import Foundation

public struct HabitLogEntity: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var date: Date
    public var progress: Int
    
    public init(id: UUID = UUID(), date: Date, progress: Int = 0) {
        self.id = id
        self.date = date
        self.progress = progress
    }
}
