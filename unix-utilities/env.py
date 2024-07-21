#!/usr/bin/env python3

# This is the result of inadvertently type `env` in my terminal and getting
# output that was unreadable.
#
# I meant to type `alias`.
#
# This script calls `env` and parses the output, color codes, and sorts it
# for easy viewing.
#
# I put it in a directory called `~/.scripts` and create an alias called `myenv`.
# This lets me run it without worrying about the PATH variable.

import subprocess

def main():
    # ANSI color codes
    COLOR_KEY = '\033[92m'  # Green
    COLOR_VALUE = '\033[94m'  # Blue
    COLOR_RESET = '\033[0m'  # Reset color

    # Call the `env` command and capture the output
    result = subprocess.run(['env'], capture_output=True, text=True)

    # Split the output into lines
    lines = result.stdout.splitlines()

    # Create a dictionary to store environment variables
    env_vars = {}

    # Populate the dictionary
    for line in lines:
        if '=' in line:
            key, value = line.split('=', 1)
            env_vars[key] = value

    # Sort the environment variables by key
    sorted_env_vars = dict(sorted(env_vars.items()))

    # Print each environment variable with indentation and color coding
    for key, value in sorted_env_vars.items():
        print(f'{COLOR_KEY}{key}{COLOR_RESET}={COLOR_VALUE}{value}{COLOR_RESET}')

if __name__ == "__main__":
    main()
