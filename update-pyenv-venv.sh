#!/bin/bash

# Date: 2024-07-14
# 
# DANGER: ALPHA Version
# 
# This has NOT been FULLY TESTED
#
# You have been warned.

# To-Do:
#
#  Test all the pieces
#  Add usage information/explanation/help
#  Add restore logic for archived settings
#  Double-check grep regex 

# update-pyenv-venv.sh
#
# Verify that pyenv is installed/initialized

export PATH="$HOME/.pyenv/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Function that displays a quit message and exit
# Abort, Retry, Fail...

quit_gracefully() {
    echo "Action canceled. Exiting."
    exit 0
}

# When an existing pyenv virtual environment exists, the script prompts
# to save the settings as an archive.  This function defines the default name.
# It uses the existing virtual environment's name, the python version,
# and the date.  To add some entropy, the hour and minute from the date
# command are concatenated.

generate_default_archive_name() {
    local env_name=$1         # Get the virtual environment name
    env_name=${env_name// /-} # Replace spaces with dashes
    local version=$2          # Get the virtual environment version number
    local date_str=$(date +%Y-%m-%d-%H%M)
    echo "${env_name}-${version}-${date_str}.tar.gz"
}

# Function to display Python versions from Pyenv in columns

display_versions_in_columns() {
    local versions=("$@")
    local num_versions=${#versions[@]}
    local columns=2
    local rows=$(((num_versions + columns - 1) / columns))

    for ((i = 0; i < rows; i++)); do
        for ((j = 0; j < columns; j++)); do
            idx=$((j * rows + i))
            if [ $idx -lt $num_versions ]; then
                printf "[%2d] %s" $((idx + 1)) "${versions[$idx]}"
                if [ $j -lt $((columns - 1)) ]; then
                    printf "\t"
                fi
            fi
        done
        echo
    done
}

# Check if a pyenv virtual environment exists in the current directory

if [ -f .python-version ]; then
    existing_env=$(pyenv version-name)
    existing_version=$(pyenv version | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$')
    echo "Current pyenv virtual environment: $existing_env"

    read -p "Backup existing virtual environment settings? (Y/n/quit): " backup_env
    backup_env=${backup_env:-Y} # Make the default == Yes
    case "$backup_env" in
    [Yy]*)
        default_archive_name=$(generate_default_archive_name "$existing_version")
        read -p "Enter the archive name (default: $default_archive_name): " archive_name
        archive_name=${archive_name:-$default_archive_name}
        pyenv virtualenvs >"${archive_name}"
        echo "Settings saved as: $archive_name"
        ;;
    quit)
        quit_gracefully
        ;;
    [Nn]*) ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
    esac

    read -p "Update or delete the existing virtual environment? (update/delete/quit): " action
    case "$action" in
    delete)
        read -p "Are you sure you want to delete the virtual environment '$existing_env'? This action cannot be undone. (y/N): " confirm_remove
        if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
            pyenv uninstall -f "$existing_env"
            rm .python-version
            echo "Virtual environment '$existing_env' removed."
        else
            echo "Remove action canceled."
            echo "Exiting."
            quit_action
        fi
        ;;
    update)
        # Proceed to update the existing virtual environment
        update_env=true
        ;;
    quit)
        quit_gracefully
        ;;
    *)
        echo "Invalid choice..."
        exit 1
        ;;
    esac
fi

# When a virtual environment does NOT exist, prompt to create one.
# When a virtual environment DOES exist, prompt to update it

if [ -z "$existing_env" ] || [ "$update_env" == true ]; then
    if [ -z "$existing_env" ]; then
        read -p "No pyenv virtual environment found. Create one? (y/N/quit): " create_new
        case "$create_new" in
        [Yy]*) ;;
        quit)
            quit_gracefully
            ;;
        *)
            echo "No action taken."
            exit 0
            ;;
        esac
    fi

    # Prompt for the number of versions to choose from
    read -p "How many versions would you like to choose from? (default: 10): " version_count
    version_count=${version_count:-10}

    # Get the list of available Python versions
    available_versions=($(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -n "$version_count" | tr -d ' '))

    # Display the menu to select the desired version

    display_versions_in_columns "${available_versions[@]}"
    echo "Select the Python version to install (type number or 'quit' to exit):"

    while :; do
        read -p "Enter the number corresponding to your choice: " version_choice
        if [[ "$version_choice" == "quit" ]]; then
            quit_gracefully
        elif [[ "$version_choice" =~ ^[0-9]+$ ]] && [ "$version_choice" -ge 1 ] && [ "$version_choice" -le "${#available_versions[@]}" ]; then
            selected_version=${available_versions[$((version_choice - 1))]}
            echo "You selected Python $selected_version"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done

    # Create or update the virtual environment
    if [ -z "$existing_env" ]; then
        read -p "Enter the name for the new virtual environment (or type 'quit' to exit): " new_env_name
        if [[ "$new_env_name" == "quit" ]]; then
            quit_gracefully
        fi

        pyenv virtualenv "$selected_version" "$new_env_name"
        pyenv local "$new_env_name"
        echo "New virtual environment '$new_env_name' created with Python $selected_version"
    else
        pyenv uninstall -f "$existing_env"
        pyenv virtualenv "$selected_version" "$existing_env"
        pyenv local "$existing_env"
        echo "Virtual environment '$existing_env' updated to Python $selected_version"
    fi
fi

# Verify the installation
python --version
pyenv version
