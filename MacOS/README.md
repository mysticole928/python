# Creating Python Virtual Evironments using MacOS

Updated: 2025-01-04

## Python, Homebrew, and a Mysterious Error

In 2024, after upgrading to the latest version of MacOS, I ran a python script and got a new and somewhat cryptic message:

```
error: externally-managed-environment
```

### Python 3.11 and PEP-668

After doing some research, this is because of PEP-668 implemented in Python 3.11. Python Enhancement Proposal (PEP) 668 creates a separation between the global Python environment (typically managed by system package managers like `apt`, `yum`, or `dnf`) and the user context where tools like pip operate. 

PEP-668 marks environments as "externally managed," to ensure that package management actions in the global context (operating system space) require explicit consent. The goal is to reducethe risk of conflicts between system-level packages and user-installed Python packages.

### MacOS and Homebrew Python

I thought, by using Homebrew, I was working outside of the global context.  It seems that, even though Homebrew python was in user space, it was too close to the OS and considered an externally managed environment.

While trying to figure out how to override PEP-668's behavior with Homebrew, it made more sense to follow best practices, remove the Homebrew version of Python, and create virtual environments.

That said, the built-in virtual enviroments has always felt cumbersome.  (At least to me.)  After some research, I opted to use **pyenv** to create a "global" virtual environment for my user space.  This keeps my user-space Python updates away from MacOS _and_ I can create additional virtual environments as needed.

## Steps to Install Pyenv, Remove Homebrew Python, and Reinstall

The steps to install/update a global Python virtual environment are outlined in the the document `pyevn-install.md`.

## Scripts

- `pyenv-update-python-zsh.sh` - Updates the Global-User version of Python managed by pyenv (zsh version)
- `pyenv-update-python-bash.sh` - Bash version of the above
- `pyevn-venv-cud.sh` - Creates pyenv virtual environments with prompts
