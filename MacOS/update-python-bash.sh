#!/bin/bash

# Date: 2024-07-14
#
# Dependencies: Pyenv
# Shell: bash
# Arguments: None
# 
# This script depends on pyenv for python management.
#
# It will get the latest version number of python and compares it to
# the version installed.  
#
# If they are different, it will prompt you asking if you want to install
# the latest version.
#
# The default is no.
#
# Author's note:  Shell scripting is a good reminder of why I use Python.

# Ensure pyenv is initialized

export PATH="$HOME/.pyenv/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Get the LATEST version of Python available from pyenv

latest_version=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')

# Get the CURRENTLY installed global Python version

current_version=$(pyenv version-name)

# Compare the versions 
# If they are different, prompt for install

if [ "$latest_version" != "$current_version" ]; then
  echo "Current Python version: $current_version"
  echo "Latest Python version available: $latest_version"
  read -p "Do you want to install the latest version? (y/N): " answer

  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    # Install the latest version of Python
    pyenv install $latest_version

    # Set the latest version as the global default

    pyenv global $latest_version

    echo "Python $latest_version has been installed and set as the global default."
  else
    echo "Python version update canceled."
  fi
else
  echo "You already have the latest Python version ($current_version) installed."
fi

# Verify the installation
echo "Built-in Python version (OS):" /usr/bin/python3 --version
echo
echo "Current global pyenv version:" pyenv version
