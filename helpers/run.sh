#!/bin/bash
# run.sh - A versatile script runner

# Default script directory
script_dir="${RUN_SCRIPT_DIR:-/usr/local/bin/fabric}"

# Log file for recording actions (optional)
log_file="/var/log/run_script.log"

# Function to display help information
show_help() {
    cat << EOF
Usage: sudo run <script_name_or_path> [options]

Options:
  --help         Show this help message and exit
  list           List all available scripts in the '$script_dir' directory
  --dir <path>   Specify an alternative directory for scripts

Description:
  The 'run' command allows you to execute any script by providing its name or path.
  The script will be made executable and then run.

Examples:
  sudo run list
    List all scripts available in the '$script_dir' directory.

  sudo run <script_name>
    Run a specific script from the '$script_dir' directory.

  sudo run --dir /path/to/scripts <script_name>
    Run a script from a custom directory.
EOF
}

# Function to log actions (optional)
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Function to list all scripts in the script_dir directory
list_scripts() {
    echo "Run any of the scripts below by running: sudo run <example>"
    for script in "$script_dir"/*; do
        if [ -f "$script" ]; then
            basename "$script"
        fi
    done
}

# Argument parsing using a case statement
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    list)
        list_scripts
        exit 0
        ;;
    --dir)
        if [ -z "$2" ]; then
            echo "Error: No directory specified with --dir option."
            exit 1
        fi
        script_dir="$2"
        shift 2
        ;;
    *)
        script_name="$1"
        ;;
esac

# If no script name was provided after processing options, show help
if [ -z "$script_name" ]; then
    echo "Error: No script name provided."
    show_help
    exit 1
fi

# Construct script path
if [[ "$script_name" != */* ]]; then
    script_path="$script_dir/$script_name"
else
    script_path="$script_name"
fi

# Check if the script exists
if [ ! -f "$script_path" ]; then
    echo "Error: Script '$script_name' not found in '$script_dir'."
    log_action "Script '$script_name' not found in '$script_dir'"
    exit 1
fi

# Make the script executable
chmod +x "$script_path"

# Log the execution
log_action "Executing script: $script_path"

# Run the script
"$script_path"