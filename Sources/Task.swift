import Foundation

enum Priority: Int, Codable, Comparable {
    case low = 1
    case medium = 2
    case high = 3

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

struct Task: Codable {
    let id: UUID
    var title: String
    var priority: Priority
    var isCompleted: Bool

    init(title: String, priority: Priority) {
        self.id = UUID()
        self.title = title
        self.priority = priority
        self.isCompleted = false
    }
}