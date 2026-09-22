import Foundation

let manager = TaskManager()
let args = CommandLine.arguments

if args.count < 2 {
    print("Usage: task-flow [add|list|done|clear] [args]")
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

case "clear":
    let removedCount = manager.clearCompleted()
    print("Cleared \(removedCount) completed tasks.")

default:
    print("Unknown command: \(command)")
}