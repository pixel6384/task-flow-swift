import Foundation

class TaskManager {
    private let storageURL: URL
    private var tasks: [Task] = []

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.storageURL = home.appendingPathComponent(".taskflow.json")
        loadTasks()
    }

    func addTask(title: String, priority: Priority) {
        let task = Task(title: title, priority: priority)
        tasks.append(task)
        saveTasks()
    }

    func listTasks() -> [Task] {
        return tasks.filter { !$0.isCompleted }.sorted { $0.priority > $1.priority }
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

    func updateTask(index: Int, newTitle: String? = nil, newPriority: Priority? = nil) -> Bool {
        let pending = listTasks()
        guard index >= 0 && index < pending.count else {
            return false
        }
        let taskToUpdate = pending[index]
        if let idx = tasks.firstIndex(where: { $0.id == taskToUpdate.id }) {
            if let title = newTitle { tasks[idx].title = title }
            if let priority = newPriority { tasks[idx].priority = priority }
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
}