import Foundation

let manager = TaskManager()
let args = CommandLine.arguments

func parseDate(_ dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: dateString)
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

if args.count < 2 {
    print("Usage: task-flow [add|list|list-all|list-completed|done|done-all|remove|archive|update|upgrade|clear|search|status|due|sort|today|filter|tags] [args]")
    exit(1)
}

let command = args[1]

switch command {
case "add":
    guard args.count >= 3 else {
        print("Error: Missing task title.")
        exit(1)
    }
    let title = args[2]
    var priority = Priority.medium
    var dueDate: Date? = nil
    var tags: Set<String> = []
    
    if args.contains("--priority high") { priority = .high }
    else if args.contains("--priority low") { priority = .low }
    
    if let dueIndex = args.firstIndex(of: "--due"), args.count > dueIndex + 1 {
        dueDate = parseDate(args[dueIndex + 1])
    }

    if let tagsIndex = args.firstIndex(of: "--tags"), args.count > tagsIndex + 1 {
        let tagsString = args[tagsIndex + 1]
        tags = Set(tagsString.components(separatedBy: ","))
    }
    
    manager.addTask(title: title, priority: priority, dueDate: dueDate, tags: tags)
    print("Task added successfully.")

case "list":
    let tasks = manager.listTasks()
    if tasks.isEmpty {
        print("No pending tasks!")
    } else {
        print("Pending Tasks (Sorted by \(manager.getSortOrder().rawValue)):")
        for (index, task) in tasks.enumerated() {
            let dueStr = task.dueDate != nil ? " (Due: \(formatDate(task.dueDate!)))" : ""
            let tagsStr = !task.tags.isEmpty ? " [\(task.tags.joined(separator: ", "))]" : ""
            print("[\(index)] [\(task.priority.description)] \(task.title)\(tagsStr)\(dueStr)")
        }
    }

case "list-completed":
    let tasks = manager.listCompletedTasks()
    if tasks.isEmpty {
        print("No completed tasks found!")
    } else {
        print("Completed Tasks (Sorted by \(manager.getSortOrder().rawValue)):")
        for task in tasks {
            let dueStr = task.dueDate != nil ? " (Due: \(formatDate(task.dueDate!)))" : ""
            let tagsStr = !task.tags.isEmpty ? " [\(task.tags.joined(separator: ", "))]" : ""
            print("[Done] [\(task.priority.description)] \(task.title)\(tagsStr)\(dueStr)")
        }
    }

case "list-all":
    let tasks = manager.listAllTasks()
    if tasks.isEmpty {
        print("No tasks found!")
    } else {
        print("All Tasks (Sorted by \(manager.getSortOrder().rawValue)):")
        for task in tasks {
            let status = task.isCompleted ? "[Done]" : "[Pending]"
            let dueStr = task.dueDate != nil ? " (Due: \(formatDate(task.dueDate!)))" : ""
            let tagsStr = !task.tags.isEmpty ? " [\(task.tags.joined(separator: ", "))]" : ""
            print("\(status) [\(task.priority.description)] \(task.title)\(tagsStr)\(dueStr)")
        }
    }

case "search":
    guard args.count >= 3 else {
        print("Error: Please provide a search term.")
        exit(1)
    }
    let query = args[2]
    let results = manager.searchTasks(query: query)
    if results.isEmpty {
        print("No tasks found matching '\(query)'.")
    } else {
        print("Search results:")
        for task in results {
            let status = task.isCompleted ? "[Done]" : "[Pending]"
            let dueStr = task.dueDate != nil ? " (Due: \(formatDate(task.dueDate!)))" : ""
            let tagsStr = !task.tags.isEmpty ? " [\(task.tags.joined(separator: ", "))]" : ""
            print("\(status) [\(task.priority.description)] \(task.title)\(tagsStr)\(dueStr)")
        }
    }

case "status":
    let stats = manager.getStats()
    print("Task Flow Status:")
    print("- Pending: \(stats.pending)")
    print("- Completed: \(stats.completed)")
    print("- Current Sort: \(manager.getSortOrder().rawValue)")

case "done":
    guard args.count >= 3, let index = Int(args[2]) else {
        print("Error: Please provide a valid task index.")
        exit(1)
    }
    if manager.completeTask(index: index) {
        print("Task marked as completed!")
    } else {
        print("Error: Task not found.")
    }

case "done-all":
    let count = manager.completeAllTasks()
    if count > 0 {
        print("Marked \(count) tasks as completed!")
    } else {
        print("No pending tasks to complete.")
    }

case "remove":
    guard args.count >= 3, let index = Int(args[2]) else {
        print("Error: Please provide a valid task index.")
        exit(1)
    }
    if manager.removeTask(index: index) {
        print("Task removed successfully!")
    } else {
        print("Error: Task not found.")
    }

case "archive":
    guard args.count >= 3, let index = Int(args[2]) else {
        print("Error: Please provide a valid task index.")
        exit(1)
    }
    if manager.archiveTask(index: index) {
        print("Task archived successfully!")
    } else {
        print("Error: Task not found.")
    }

case "update":
    guard args.count >= 3, let index = Int(args[2]) else {
        print("Error: Usage: task-flow update [index] [title <new title>] [priority <high|medium|low>] [due <yyyy-MM-dd>] [tags <t1,t2>]")
        exit(1)
    }
    
    var newTitle: String? = nil
    var newPriority: Priority? = nil
    var newDueDate: Date? = nil
    var newTags: Set<String>? = nil
    
    var i = 3
    while i < args.count {
        let key = args[i]
        if i + 1 < args.count {
            let value = args[i+1]
            if key == "title" {
                newTitle = value
                i += 2
            } else if key == "priority" {
                let p = value.lowercased()
                if p == "high" { newPriority = .high }
                else if p == "medium" { newPriority = .medium }
                else if p == "low" { newPriority = .low }
                i += 2
            } else if key == "due" {
                newDueDate = parseDate(value)
                i += 2
            } else if key == "tags" {
                newTags = Set(value.components(separatedBy: ","))
                i += 2
            } else {
                i += 1
            }
        } else {
            i += 1
        }
    }
    
    if newTitle == nil && newPriority == nil && newDueDate == nil && newTags == nil {
        print("Error: Please specify what to update: 'title <text>', 'priority <level>', 'due <yyyy-MM-dd>', or 'tags <t1,t2>'")
        exit(1)
    }

    if manager.updateTask(index: index, newTitle: newTitle, newPriority: newPriority, newDueDate: newDueDate, newTags: newTags) {
        print("Task updated successfully!")
    } else {
        print("Error: Task not found.")
    }

case "upgrade":
    guard args.count >= 3, let index = Int(args[2]) else {
        print("Error: Usage: task-flow upgrade [index]")
        exit(1)
    }
    if let newPriority = manager.upgradePriority(index: index) {
        print("Task priority upgraded to \(newPriority.description)!")
    } else {
        print("Error: Task not found.")
    }

case "clear":
    let removedCount = manager.clearCompleted()
    print("Cleared \(removedCount) completed tasks.")

case "due":
    guard args.count >= 4, let index = Int(args[2]) else {
        print("Error: Usage: task-flow due [index] [yyyy-MM-dd]")
        exit(1)
    }
    if let date = parseDate(args[3]) {
        if manager.updateTask(index: index, newDueDate: date) {
            print("Due date updated successfully!")
        } else {
            print("Error: Task not found.")
        }
    } else {
        print("Error: Invalid date format. Please use yyyy-MM-dd.")
    }

case "sort":
    guard args.count >= 3 else {
        print("Error: Usage: task-flow sort [priority|due]")
        exit(1)
    }
    let sortArg = args[2].lowercased()
    if sortArg == "priority" {
        manager.setSortOrder(.priority)
        print("Tasks will now be sorted by priority.")
    } else if sortArg == "due" {
        manager.setSortOrder(.dueDate)
        print("Tasks will now be sorted by due date.")
    } else {
        print("Error: Invalid sort order. Use 'priority' or 'due'.")
    }

case "today":
    let tasks = manager.listTodayTasks()
    if tasks.isEmpty {
        print("No tasks due today!")
    } else {
        print("Tasks Due Today (Sorted by \(manager.getSortOrder().rawValue)):")
        for (index, task) in tasks.enumerated() {
            let tagsStr = !task.tags.isEmpty ? " [\(task.tags.joined(separator: ", "))]" : ""
            print("[\(index)] [\(task.priority.description)] \(task.title)\(tagsStr)")
        }
    }

case "filter":
    guard args.count >= 3 else {
        print("Error: Usage: task-flow filter [high|medium|low]")
        exit(1)
    }
    let filterArg = args[2].lowercased()
    var priority: Priority?
    if filterArg == "high" { priority = .high }
    else if filterArg == "medium" { priority = .medium }
    else if filterArg == "low" { priority = .low }
    
    guard let p = priority else {
        print("Error: Invalid priority. Use 'high', 'medium', or 'low'.")
        exit(1)
    }

    let tasks = manager.listTasks(withPriority: p)
    if tasks.isEmpty {
        print("No pending tasks with priority \(p.description)!")
    } else {
        print("Pending \(p.description) Priority Tasks:")
        for (index, task) in tasks.enumerated() {
            let dueStr = task.dueDate != nil ? " (Due: \(formatDate(task.dueDate!)))" : ""
            let tagsStr = !task.tags.isEmpty ? " [\(task.tags.joined(separator: ", "))]" : ""
            print("[\(index)] \(task.title)\(tagsStr)\(dueStr)")
        }
    }

case "tags":
    guard args.count >= 3 else {
        print("Error: Usage: task-flow tags [tag_name]")
        exit(1)
    }
    let tag = args[2]
    let tasks = manager.listTasks(withTag: tag)
    if tasks.isEmpty {
        print("No pending tasks with tag '\(tag)'!")
    } else {
        print("Pending Tasks tagged as '\(tag)':")
        for (index, task) in tasks.enumerated() {
            let dueStr = task.dueDate != nil ? " (Due: \(formatDate(task.dueDate!)))" : ""
            let tagsStr = !task.tags.isEmpty ? " [\(task.tags.joined(separator: ", "))]" : ""
            print("[\(index)] [\(task.priority.description)] \(task.title)\(tagsStr)\(dueStr)")
        }
    }

default:
    print("Unknown command: \(command)")
}