#!/bin/bash

TASK_DIR="/home/aman/.tasks"
TASK_FILE="$TASK_DIR/tasks.json"
TMP_FILE="$TASK_DIR/tmp.json"
TASK_STATUS=("idle" "ongoing" "completed")

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Check if the directory exists; if not, create a new directory in the home folder
[ ! -d "$TASK_DIR" ] && mkdir "$TASK_DIR"

# Check for the tasks file. If it does not exist, create a new file 
# and initialize it with a tasks array to store the tasks
if [ ! -f "$TASK_FILE" ]; then
    touch "$TASK_FILE" 
    echo '{"tasks": []}' > "$TASK_FILE"
fi

# Function to add a task or multiple tasks
add_task() {
    # Check if no task name is provided
    if [ -z "$1" ]; then
        echo "Please provide the name(s) of the task(s)."
        return 1
    fi

    # Loop through all provided task names and add them
    for task_name in "$@"; do 
        echo "Adding task: $task_name"

        # Find max id of existing tasks and add 1 for the next task
        if jq --arg name "$task_name" --arg status "${TASK_STATUS[0]}" \
            '.tasks += [{"id": ((.tasks | map(.id) | max // 0) + 1), "name": $name, "status": $status}]' \
            "$TASK_FILE" > "$TMP_FILE"; then

            # Check if data is added to tmp file
            if [ -s "$TMP_FILE" ]; then
                mv "$TMP_FILE" "$TASK_FILE"
                echo "Task added successfully!"
            else
                echo "Error: Temporary file is empty. Task not added."
            fi
        else
            echo "Error: Failed to update tasks file."
        fi
    done
}

# Function to delete a task by ID
delete_task() {
    if [ -z "$1" ]; then
        echo "Error: Task ID is required."
        return 1
    fi

    # Loop through all provided task IDs and delete them
    for task_id in "$@"; do
        echo "Deleting task with ID: $task_id"

        # Filter tasks to exclude the provided ID
        if jq --argjson id "$task_id" \
            '.tasks |= map(select(.id != $id))' \
            "$TASK_FILE" > "$TMP_FILE"; then
            if [ -s "$TMP_FILE" ]; then
                mv "$TMP_FILE" "$TASK_FILE"
                echo "Task deleted successfully!"
            else
                echo "Error: Temporary file is empty. Task not deleted."
            fi
        else
            echo "Error: Failed to delete task."
        fi
    done
}

# Function to clear all tasks with confirmation
clear_all() {
    echo "This will delete all the existing tasks."
    read -p "Are you sure you want to proceed? (y/n): " confirmation
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
        rm "$TASK_FILE"
        echo '{"tasks": []}' > "$TASK_FILE"
        echo "All tasks cleared successfully."
    else
        echo "Operation cancelled."
    fi
}

# Function to update a task by ID
update_task() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Please specify the ID and the updated name of the task!"
        return 1
    fi

    local task_id="$1"
    local new_name="$2"

    # Update the name of the task with the specified ID
    if jq --argjson id "$task_id" --arg name "$new_name" \
        '.tasks |= map(if .id == ($id | tonumber) then .name = $name else . end)' \
        "$TASK_FILE" > "$TMP_FILE"; then 
        if [ -s "$TMP_FILE" ]; then 
            mv "$TMP_FILE" "$TASK_FILE"
            echo "Task updated successfully."
        else 
            echo "Error: Temporary file is empty. Task not updated."
        fi
    else 
        echo "Error: Failed to update task."
    fi
}

update_status() {
    if [ -z "$1" ]; then 
        echo "Please provide the ID of the task."
        return 1
    fi 

    local task_status="$1"
    shift

    # Loop through all provided task IDs and mark them as idle
    for task_id in "$@"; do
        if jq --argjson id "$task_id" --arg status "$task_status" \
            '.tasks |= map(if .id == ($id | tonumber) then .status = $status else . end)' \
            "$TASK_FILE" > "$TMP_FILE"; then 
            if [ -s "$TMP_FILE" ]; then 
                mv "$TMP_FILE" "$TASK_FILE"
                echo "Task marked as $task_status."
            else 
                echo "Error: Temporary file is empty. Task not updated."
            fi
        else 
            echo "Error: Failed to mark task as idle."
        fi
    done
}

# Function to list all tasks
list_tasks() {

    if [ ! -s "$TASK_FILE" ]; then 
        echo -e "${RED}No tasks found.${RESET}"
        return
    fi

     # Display header
    printf "${CYAN}%-5s %-30s %-15s${RESET}\n" "ID" "Name" "Status"
    printf "${CYAN}%-5s %-30s %-15s${RESET}\n" "----" "------------------------------" "---------------"


    # Read and display tasks
    jq -r '
        if .tasks | length == 0 then 
            "No tasks found." 
        else 
            .tasks[] | "\(.id): \(.name) \(.status)" 
        end
    ' "$TASK_FILE" | while IFS=$'\t' read -r id name status; do
        case "$status" in
            idle) color=$YELLOW ;;
            ongoing) color=$CYAN ;;
            completed) color=$GREEN ;;
            *) color=$RESET ;;
        esac
        printf "%-5s %-30s ${color}%-15s${RESET}\n" "$id" "$name" "$status"
    done < <(
        jq -r '.tasks[] | "\(.id)\t\(.name)\t\(.status)"' "$TASK_FILE"
    )
}


# Function to list tasks filtered by status
list_done() {
    list_by_status "${TASK_STATUS[2]}"
}

list_ongoing() {
    list_by_status "${TASK_STATUS[1]}"
}

list_idle() {
    list_by_status "${TASK_STATUS[0]}"
}

list_by_status() {
    local status="$1"
    if [ ! -s "$TASK_FILE" ]; then 
        echo "No tasks found."
        return
    fi

    # Read and display tasks based on the status
    echo "Tasks with status: $status"
    jq --arg status "$status" -r '
        .tasks | map(select(.status == $status)) | 
        if length == 0 then "No tasks with status \($status) found." 
        else .[] | "\(.id)\t\(.name)\t\(.status)" end' "$TASK_FILE" | while IFS=$'\t' read -r id name status; do
        case "$status" in
            idle) color=$YELLOW ;;
            ongoing) color=$CYAN ;;
            completed) color=$GREEN ;;
            *) color=$RESET ;;
        esac
        printf "%-5s %-30s ${color}%-15s${RESET}\n" "$id" "$name" "$status"
    done
}


# Function to display usage information
show_usage() {
    echo "Usage: ./task-cli.sh [command] [arguments...]"
    echo "Commands:"
    echo "  add [task_name ...]          Add one or more tasks."
    echo "  delete [task_id ...]         Delete one or more tasks by ID."
    echo "  clear                        Clear all tasks after confirmation."
    echo "  update [task_id] [new_name]  Update the name of a task by ID."
    echo "  mark-done [task_id ...]      Mark one or more tasks as completed."
    echo "  mark-ongoing [task_id ...]   Mark one or more tasks as ongoing."
    echo "  mark-idle [task_id ...]      Mark one or more tasks as idle."
    echo "  list                         List all tasks."
    echo "  list-done                   List tasks marked as completed."
    echo "  list-ongoing                List tasks marked as ongoing."
    echo "  list-idle                   List tasks marked as idle."
    echo "  help                        Show this usage information."
}

# Main script logic using a case statement
case "$1" in 
    add)
        shift
        add_task "$@"
        ;;

    delete)
        shift 
        delete_task "$@"
        ;;

    clear)
        clear_all
        ;;

    update)
        shift
        update_task "$@"
        ;;

    mark-done)
        shift 
        update_status "${TASK_STATUS[2]}" "$@"
        ;;

    mark-ongoing)
        shift 
        update_status "${TASK_STATUS[1]}" "$@"
        ;;

    mark-idle)
        shift
        update_status "${TASK_STATUS[0]}" "$@"
        ;;

    list)
        list_tasks
        ;;

    list-done)
        list_done
        ;;

    list-ongoing)
        list_ongoing
        ;;

    list-idle)
        list_idle
        ;;

    help)
        show_usage
        ;;

    *)
        show_usage
        ;;
esac
