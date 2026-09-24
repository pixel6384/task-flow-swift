import Foundation

enum SortOrder: String, Codable {
    case priority
    case dueDate
}

class TaskManager {
    private let storageURL: URL
    private let settingsURL: URL
    private var tasks: [Task] = []
    private var sortOrder: SortOrder = .priority

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.storageURL = home.appendingPathComponent(".taskflow.json")
        self.settingsURL = home.appendingPathComponent(".taskflow-settings.json")
        loadSettings()
        loadTasks()
    }

    func setSortOrder(_ order: SortOrder) {
        self.sortOrder = order
        saveSettings()
    }

    func getSortOrder() -> SortOrder {
        return sortOrder
    }

    func addTask(title: String, priority: Priority, dueDate: Date? = nil) {
        let task = Task(title: title, priority: priority, dueDate: dueDate)
        tasks.append(task)
        saveTasks()
    }

    func listTasks() -> [Task] {
        return tasks.filter { !$0.isCompleted }.sorted { sortTasks($0, $1) }
    }

    func listCompletedTasks() -> [Task] {
        return tasks.filter { $0.isCompleted }.sorted { sortTasks($0, $1) }
    }

    func listAllTasks() -> [Task] {
        return tasks.sorted { sortTasks($0, $1) }
    }

    func listTodayTasks() -> [Task] {
        let calendar = Calendar.current
        return tasks.filter {
            !$0.isCompleted && calendar.isDateInToday($0.dueDate ?? Date.distantFuture)
        }.sorted { sortTasks($0, $1) }
    }

    func listTasks(withPriority priority: Priority) -> [Task] {
        return tasks.filter { !$0.isCompleted && $0.priority == priority }.sorted { sortTasks($0, $1) }
    }

    private func sortTasks(_ lhs: Task, _ rhs: Task) -> Bool {
        switch sortOrder {
        case .priority:
            if lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }
            return (lhs.dueDate ?? Date.distantFuture) < (rhs.dueDate ?? Date.distantFuture)
        case .dueDate:
            if (lhs.dueDate ?? Date.distantFuture) != (rhs.dueDate ?? Date.distantFuture) {
                return (lhs.dueDate ?? Date.distantFuture) < (rhs.dueDate ?? Date.distantFuture)
            }
            return lhs.priority > rhs.priority
        }
    }

    func searchTasks(query: String) -> [Task] {
        return tasks.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    func getStats() -> (pending: Int, completed: Int) {
        let pending = tasks.filter { !$0.isCompleted }.count
        let completed = tasks.filter { $0.isCompleted }.count
        return (pending, completed)
    }

    func completeTask(index: Int) -> Bool {
        let pending = listTasks()
        guard index >= 0 && index < pending.count else {
            return false
        }
        let taskToComplete = pending[index]
        if let idx = tasks.firstIndex(where: { $0.id == taskToComplete.id }) {
            tasks[idx].isCompleted = true
            saveTasks()
            return true
        }
        return false
    }

    func completeAllTasks() -> Int {
        var count = 0
        for i in 0..<tasks.count {
            if !tasks[i].isCompleted {
                tasks[i].isCompleted = true
                count += 1
            }
        }
        saveTasks()
        return count
    }

    func removeTask(index: Int) -> Bool {
        let pending = listTasks()
        guard index >= 0 && index < pending.count else {
            return false
        }
        let taskToRemove = pending[index]
        if let idx = tasks.firstIndex(where: { $0.id == taskToRemove.id }) {
            tasks.remove(at: idx)
            saveTasks()
            return true
        }
        return false
    }

    func updateTask(index: Int, newTitle: String? = nil, newPriority: Priority? = nil, newDueDate: Date? = nil) -> Bool {
        let pending = listTasks()
        guard index >= 0 && index < pending.count else {
            return false
        }
        let taskToUpdate = pending[index]
        if let idx = tasks.firstIndex(where: { $0.id == taskToUpdate.id }) {
            if let title = newTitle { tasks[idx].title = title }
            if let priority = newPriority { tasks[idx].priority = priority }
            if let dueDate = newDueDate { tasks[idx].dueDate = dueDate }
            saveTasks()
            return true
        }
        return false
    }

    func clearCompleted() -> Int {
        let initialCount = tasks.count
        tasks.removeAll { $0.isCompleted }
        saveTasks()
        return initialCount - tasks.count
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            try? data.write(to: storageURL)
        }
    }

    private func loadTasks() {
        if let data = try? Data(contentsOf: storageURL),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(sortOrder) {
            try? data.write(to: settingsURL)
        }
    }

    private func loadSettings() {
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(SortOrder.self, from: data) {
            sortOrder = decoded
        }
    }
}