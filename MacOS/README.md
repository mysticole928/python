# Python Virtual Evironments on MacOS

Date: 2024-07-20

These scripts create and update Python virtual environments on MacOS

They're designed for hobby-coders.

## Python MacOS PEP-668

The file `python-macos-pep-668.md` explains how to manage the update to Homebrew
related to PEP 668.  For years, an easy way to manage Python 3 on the Mac was
using Homebrew.  PEP 668 makes virtual environments a requirement but it doesn't 
explain how to easily manage them.

## Update Python

The steps to install/update a global Python virtual environment are outlined in the 
the document `python-macos-pep-668.md`.

The script `update-python.sh` automates the process.

## Create, Update, or Delete Python Virtual Environments

The shell script `update-python.sh` creates a global Python virtual environment.

If a separate virtual environment is needed in a specific directory, use the
shell script `pyenv-venv-cud.sh`.

It automate a number of tasks.

### It can create a new virtual environment

The script will checkt to see if a virtual environment exists.  
If **not**, it will prompt to create one.

It will prompt for a name for the new virtual environment.

A default vitual environment is automatically generated based on the directory name.
If there are spaces in the name, they are replaced with dashes.

It will prompt for a number of past Python versions to choose from.  The default number is 10.  
These are presented as a numbered menu.

If a chosen Python version is not currently part of `pyenv`, it is installed.

### If there is a virtual environment

The script checks to see if there is a virtual environment.  If there is, the version can be changed or deleted.

Before doing either, the script prompts to create a backup archive of the settings.

If the environment is deleted, it's settings are automatically archived.  

If you **do not** opt to create an archive when prompted, the script automatically creates one.

