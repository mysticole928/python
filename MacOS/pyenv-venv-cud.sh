#!/bin/bash

###########################################################
#                                                         #
#                      update-pyenv-venv.sh               #
#                                                         #
#   This script manages pyenv virtual environments.       #
#   It can create, update, delete, and archive            #
#   virtual environments.                                 #
#                                                         #
#   Date: 2024-07-20                                      #
#   Version: 2.1                                          #
#   Found a bug where, if the virtual environment was not #
#   already installed in pyenv, the script would crash.   #
#   Added a test to check and install if needed.          #
#                                                         #
# This script modifies pyenv virtual environments         #
#                                                         #
# It...                                                   #
#                                                         #
#   ...checks to see if a virtual environment exists and  #
#      prompts to create a new one                        #
#                                                         #
#   ...updates an existing virtual environment            #
#                                                         #
#   ...deletes an existing virtual environment            #
#                                                         #
# The update process includes an option to archive the    #
# existing settings                                       #
#                                                         #
# When removing/deleting a virtual environment, the       #
# settings are automatically archived                     #
#                                                         #
###########################################################

# Verify that pyenv is installed/initialized

export PATH="$HOME/.pyenv/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
else
    echo "pyenv is not installed or not initialized correctly. Exiting."
    exit 1
fi

# Brief description of the script
echo "This script manages pyenv virtual environments."
echo "It can create, update, delete, and archive them."
echo

# Prompt to continue or quit
read -p "Continue? (Y/n): " continue_script
continue_script=${continue_script:-Y}

if [[ "$continue_script" =~ ^[Nn]$ ]]; then
    echo "Exiting script."
    exit 0
fi

# Sanitize name by replacing spaces with dashes
# Used when creating default venv names.
# The default names are based on the current directory name.

function replace_spaces {
    echo "$1" | tr ' ' '-'
}

# Get the current directory name

current_dir=$(basename "$PWD")
env_name=$(replace_spaces "$current_dir")

# Function that displays a quit message and exits
# Abort, Retry, Fail...

quit_gracefully() {
    echo "Action canceled. Exiting."
    exit 0
}

# When an existing pyenv virtual environment exists, the script prompts
# to save the settings as an archive. This function defines the default name.
# It uses the existing virtual environment's name, the python version,
# and the date. To add some entropy, the hour and minute from the date
# command are concatenated.

generate_default_archive_name() {
    local env_name=$1         # Get the virtual environment name
    env_name=${env_name// /-} # Replace spaces with dashes
    local version=$2          # Get the virtual environment version number
    local date_str=$(date +%Y-%m-%d-%H%M)
    echo "${env_name}-${version}-${date_str}.tar.gz"
}

# Function that displays Python versions from Pyenv in columns

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

# Check if a pyenv virtual environment exists

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

    read -p "Update or delete existing virtual environment? (update/delete/quit): " action
    case "$action" in
    delete)
        read -p "Are you sure you want to delete the virtual environment '$existing_env'? (y/N): " confirm_remove
        if [[ "$confirm_remove" =~ ^[Yy]$ ]]; then
            # Automatically archive before deleting
            default_archive_name=$(generate_default_archive_name "$existing_env" "$existing_version")
            pyenv virtualenvs >"${default_archive_name}"
            echo "Settings saved as: $default_archive_name"

            # Delete virtual environment
            pyenv uninstall -f "$existing_env"
            rm .python-version
            echo "Virtual environment '$existing_env' removed."
        else
            echo "Delete action canceled."
            echo "Exiting."
            quit_gracefully
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

# Function to check if a Python version is installed and install it if not
check_and_install_python_version() {
    local version=$1
    if ! pyenv versions --bare | grep -q "^${version}$"; then
        echo "Python version $version is not installed. Installing..."
        pyenv install "$version"
    else
        echo "Python version $version is already installed."
    fi
}

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

    # Ask if they want the current global pyenv version of Python
    global_version=$(pyenv global)
    read -p "Do you want to use the current global pyenv version ($global_version)? (y/n/quit): " use_global

    if [[ "$use_global" == "quit" ]]; then
        quit_gracefully
    elif [ "$use_global" = "y" ]; then
        selected_version=$global_version
    else
        # Prompt for the number of versions to choose from
        read -p "How many versions would you like to choose from? (default: 10): " version_count
        version_count=${version_count:-10}

        # Get the list of available Python versions
        available_versions=($(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -n "$version_count" | tr -d ' '))

        # Display the menu to select the desired version

        display_versions_in_columns "${available_versions[@]}"
        echo "Select the Python version to install (type number or 'quit' to exit):"

        while :; do
            read -p "Please select the number of your chosen option: " version_choice
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
    fi

    # Check and install the selected Python version if necessary
    check_and_install_python_version "$selected_version"

    # Create or update the virtual environment
    if [ -z "$existing_env" ]; then
        read -p "Enter the name for the new virtual environment (default: $env_name, or type 'quit' to exit): " new_env_name
        new_env_name=${new_env_name:-$env_name}
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
