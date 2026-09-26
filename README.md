# TaskFlow Swift

TaskFlow is a minimalist CLI task manager built with Swift. It allows you to quickly add, list, and complete tasks with priority levels.

## Features
- Add tasks with priority (High, Medium, Low)
- List pending tasks sorted by priority
- Mark tasks as completed
- Persistent storage in JSON format
- Pomodoro timer for focused work
- Export task lists to text files

## Usage
`swift run task-flow add "Finish report" --priority high`
`swift run task-flow list`
`swift run task-flow done 1`
`swift run task-flow pomodoro 0`
`swift run task-flow export tasks.txt`