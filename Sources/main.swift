import Foundation

let manager = TaskManager()
let args = CommandLine.arguments

if args.count < 2 {
    print("Usage: task-flow [add|list|list-all|done|remove|update|clear|search|status] [args]")
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
    if args.contains("--priority high") { priority = .high }
    else if args.contains("--priority low") { priority = .low }
    
    manager.addTask(title: title, priority: priority)
    print("Task added successfully.")

case "list":
    let tasks = manager.listTasks()
    if tasks.isEmpty {
        print("No pending tasks!")
    } else {
        print("Pending Tasks:")
        for (index, task) in tasks.enumerated() {
            print("[\(index)] [\(task.priority.description)] \(task.title)")
        }
    }

case "list-all":
    let tasks = manager.listAllTasks()
    if tasks.isEmpty {
        print("No tasks found!")
    } else {
        print("All Tasks:")
        for task in tasks {
            let status = task.isCompleted ? "[Done]" : "[Pending]"
            print("\(status) [\(task.priority.description)] \(task.title)")
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
            print("\(status) [\(task.priority.description)] \(task.title)")
        }
    }

case "status":
    let stats = manager.getStats()
    print("Task Flow Status:")
    print("- Pending: \(stats.pending)")
    print("- Completed: \(stats.completed)")

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

case "update":
    guard args.count >= 3, let index = Int(args[2]) else {
        print("Error: Usage: task-flow update [index] [\"title <new title>\"] [\"priority <high|medium|low>\"]")
        exit(1)
    }
    
    var newTitle: String? = nil
    var newPriority: Priority? = nil
    
    if args.count >= 4 {
        if args[3] == "title" && args.count >= 5 {
            newTitle = args[4]
        } else if args[3] == "priority" && args.count >= 5 {
            let p = args[4].lowercased()
            if p == "high" { newPriority = .high }
            else if p == "medium" { newPriority = .medium }
            else if p == "low" { newPriority = .low }
        }
    }
    
    if newTitle == nil && newPriority == nil {
        print("Error: Please specify what to update: 'title <text>' or 'priority <level>'")
        exit(1)
    }

    if manager.updateTask(index: index, newTitle: newTitle, newPriority: newPriority) {
        print("Task updated successfully!")
    } else {
        print("Error: Task not found.")
    }

case "clear":
    let removedCount = manager.clearCompleted()
    print("Cleared \(removedCount) completed tasks.")

default:
    print("Unknown command: \(command)")
}