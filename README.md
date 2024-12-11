# Task Manager CLI

**A simple, feature-rich command-line interface (CLI) tool for managing your tasks efficiently.**

---

## Features

- **Add Tasks**: Create one or more tasks easily.
- **Delete Tasks**: Remove tasks by their ID.
- **Update Tasks**: Rename tasks by ID.
- **Mark Status**: Set tasks as `idle`, `ongoing`, or `completed`.
- **List Tasks**: View tasks in a clean, tabular format with color-coded statuses.
- **Filter Tasks**: List tasks by specific statuses.
- **Clear Tasks**: Remove all tasks with a confirmation prompt.

---

## Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Patel-Aman/task-cli.git
   ```

2. **Navigate to the Directory:**
   ```bash
   cd task-cli
   ```

3. **Make the Script Executable:**
   ```bash
   chmod +x task-cli.sh
   ```

4. **Run the Script:**
   ```bash
   ./task-cli.sh [command] [arguments]
   ```

---

## Usage

### General Syntax:
```bash
./task-cli.sh [command] [arguments...]
```

### Available Commands:

| Command              | Description                                  | Example                                      |
|----------------------|----------------------------------------------|----------------------------------------------|
| `add [task_name...]` | Add one or more tasks.                      | `./task-cli.sh add "Task 1" "Task 2"`       |
| `delete [task_id...]`| Delete one or more tasks by ID.             | `./task-cli.sh delete 1 2`                   |
| `update [task_id] [new_name]` | Update a task's name by ID.       | `./task-cli.sh update 1 "New Task Name"`     |
| `mark-done [task_id...]` | Mark tasks as completed.                 | `./task-cli.sh mark-done 1`                  |
| `mark-ongoing [task_id...]` | Mark tasks as ongoing.                | `./task-cli.sh mark-ongoing 2`               |
| `mark-idle [task_id...]` | Mark tasks as idle.                      | `./task-cli.sh mark-idle 3`                  |
| `list`               | List all tasks in a formatted table.        | `./task-cli.sh list`                         |
| `list-done`          | List only completed tasks.                  | `./task-cli.sh list-done`                    |
| `list-ongoing`       | List only ongoing tasks.                    | `./task-cli.sh list-ongoing`                 |
| `list-idle`          | List only idle tasks.                       | `./task-cli.sh list-idle`                    |
| `clear`              | Delete all tasks after confirmation.        | `./task-cli.sh clear`                        |
| `help`               | Show usage information.                     | `./task-cli.sh help`                         |

---

## Examples

### Adding Tasks:
```bash
./task-cli.sh add "Write Report" "Prepare Presentation"
```

### Listing Tasks:
```bash
./task-cli.sh list
```
**Output:**
```
ID    Name                            Status         
----  ------------------------------  ---------------
1     Write Report                   ongoing        
2     Prepare Presentation           idle           
```

### Updating Tasks:
```bash
./task-cli.sh update 1 "Write Final Report"
```

### Marking Tasks as Completed:
```bash
./task-cli.sh mark-done 1
```

---

## Color Coding

- **Yellow (Idle)**: Tasks that are yet to start.
- **Cyan (Ongoing)**: Tasks currently in progress.
- **Green (Completed)**: Tasks that are finished.

---

## Configuration

The script uses a JSON file for task storage located at:
```
~/.tasks/tasks.json
```
This file is created automatically if it doesn't exist.

---

## Troubleshooting

- **Issue:** Command not recognized.
  - **Solution:** Run `./task-cli.sh help` to view available commands.

- **Issue:** Task file is missing or corrupted.
  - **Solution:** Delete the file at `~/.tasks/tasks.json`. A new one will be created automatically.

---

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

**Start managing your tasks today with the Task Manager CLI!**

