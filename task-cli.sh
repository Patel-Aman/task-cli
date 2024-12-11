#!/bin/bash

TASK_DIR="/home/aman/.tasks"
TASK_FILE="$TASK_DIR/tasks.json"
TMP_FILE="$TASK_DIR/tmp.json"

# check if the directory exists if not create a new directory in home folder
[ ! -d "$TASK_DIR" ] && mkdir "$TASK_DIR"

# check for the tasks file. If does not exist create a new file 
# initialize it with tasks array to store the tasks
if [ ! -f "$TASK_FILE" ]; then
    touch "$TASK_FILE"
    echo '{"tasks": []}' > "$TASK_FILE"
fi


add_task() {
    # check if the string (i.e. the task is not empty)
    # -z throws true if string is empty
    if [ -z "$1" ]; then
        echo "please provide name of the task"
    fi

    echo "Adding task: $1"

    # find max id of existing tasks and add 1 for the next task
    if jq --arg name "$1" \
          '.tasks += [{"id": ((.tasks | map(.id) | max // 0) + 1), "name": $name, "status": "idle"}]' \
          "$TASK_FILE" > "$TMP_FILE"; then

        # -s returns true if file file exist and has size greater than 0
        # check if data is added to tmp file

        if [ -s "$TMP_FILE" ]; then
            mv "$TMP_FILE" "$TASK_FILE"
            echo "Task added successfully!"
        else
            echo "Error: Temporary file is empty. Task not added."
        fi
    else
        echo "Error: Failed to update tasks file."
    fi

    echo "Updated tasks file content:"
    cat "$TASK_FILE"
}

delete_task() {
    if [ -z "$1" ]; then
        echo "Error: Task ID is required."
        return 1
    fi

    local task_id="$1"

    echo "Deleting task with ID: $task_id"

    # filter the data based on provided id to not include the provided id task
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
}

clear_all() {
    read -p "Are you sure you want to proceed? (y/n): " confirmation
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
        rm "$TASK_FILE"
        echo "task cleared successfully"
    else
        echo "Operation cancelled."
        exit 1
    fi
}

update_task() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Please specify ID and updated name of task!"
        return 1
    fi

    local task_id="$1"
    local new_name="$2"

    if jq --argjson id "$task_id" --arg name "$new_name" \
        '.tasks |= map(if .id == ($id | tonumber) then .name = $name else . end)' \
        "$TASK_FILE" > "$TMP_FILE"; then 
        if [ -z "$TMP_FILE" ]; then 
            mv "$TMP_FILE" "$TASK_FILE"
            echo "Task updated successfully"
        else 
            echo "Error: Temporary file is empty. Task not updates."
        fi
    else 
        echo "Error: Failed to delete task."
    fi
}

mark_as_done() {
    echo "marked as done"
}

mark_ongoing() {
    echo "marked as ongoing"
}

mark_idle() {
    echo "marked as idle"
}

list_tasks() {
    echo "list of tasks"
}

list_done() {
    echo "list of completed tasks"
}

list_ongoing() {
    echo "list of ongoing tasks"
}

list_idle() {
    echo "list of idle tasks"
}  

show_usage() {
    echo "list of commands"
}

case "$1" in 
    # CRUD operation
    # Add new task
    add)
        shift
        add_task "$*"
        ;;

    # Delete a task
    delete)
        shift 
        delete_task "$*"
        ;;

    # remove all the tasks
    clear)
        clear_all
        ;;

    # update given task
    update)
        update_task "$1"
        ;;

    # Status Update
    # mark as completed
    mark-done)
        shift 
        mark_as_done "$*"
        ;;

    # mark as in progress
    mark-ongoing)
        shift 
        mark_ongoing "$*"
        ;;

    # mark as idle, default status of tasks
    mark-idle)
        shift 
        mark_idle "$*"
        ;;

    # show the tasks
    # Show all the tasks
    list)
        list_tasks
        ;;

    # show all completed tasks
    list-done)
        list_done
        ;;

    # show ongoing tasks
    list-ongoing)
        list_ongoing
        ;;

    # show idle tasks
    list-idle)
        list_idle
        ;;

    *)
        show_usage
        exit 1
        ;;
esac