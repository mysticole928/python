# Installing Pyenv on MacOS

Updated: 2025-01-04

Tried to update this to make it more readable.

## Warning!

If you've set the environmental variable `CSFLAGS` there's a chance `pyenv` will return an error.  For example, the Harvard CS-50 courseware sets `CSFLAGS` that interfere with the install and update process.

As a workaround (until I can figure out exactly why the error appears) set this first:

```shell
export CFLAGS="-std=c11"
```

In the case of the CS-50 courseware, this option is already set.  One of the other ones used causes the problems.

This is true of my update scripts too.

## The Python Message of Doom

As Python coders go, I am a hobbiest.

My code automates tasks and--usually/hopefully--does one or two things well.

For years, I have enjoyed Homebrew' installation of Python 3 because it let me install and update Python without worrying if I was going to break the OS.

When Apple included Python 3.11 in MacOS, the Homebrew version stopped working.  When I tried to install a module I got a scary message:

```text
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.

    If you wish to install a non-Debian-packaged Python package,
    create a virtual environment using python3 -m venv path/to/venv.
    Then use path/to/venv/bin/python and path/to/venv/bin/pip. Make
    sure you have python3-full installed.

    If you wish to install a non-Debian packaged Python application,
    it may be easiest to use pipx install xyz, which will manage a
    virtual environment for you. Make sure you have pipx installed.

note: If you believe this is a mistake, please contact your Python installation or OS
distribution provider. You can override this, at the risk of breaking your Python
installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
```

> [!NOTE]
> 
> **Am I the punchline of a joke?**
> 
> At the time this happened, I couldn't really figure out what the error message meant, where it came from, or how to fix it.  
> 
> Paraphrasing the end of that joke: Everything you told me is technically correct and accurate but things are still unclear and I have no clue what steps I need to take.
>

## A Fix: Pyenv

There's a bit of irony with Python and virtual environments.  PEP 20, _the Zen of Python_, says the best way to approach Python code is to strive for _one - and preferably only one - obvious way_ to do something.  Creating virtual environments is part of Python.

Python's built-in virtual environment functionality has always felt cumbersome.

Though, some of my early research around installing and using `pyenv` felt like someone walking me through a grade school arithmetic problem using calculus.

The process of installing and using `pyenv` _can_ be complex **but** it is **not** complicated.

> [!TIP]
>
> **Pyenv Overview**
>
> Pyenv is a tool used manage multiple versions of Python. It allows you to install, switch, and use different Python versions as needed.
> 
> With pyenv, python versions can be set globally and per-project.
> 
> It works by shimming Python commands. Shims are lightweight wrappers that determine which specific Python version or executable to use. When you run python, pyenv uses those shims to decide which version to execute based on the environment settings.
>
> However, `pyenv` can also create individual virtual environments for Python.  In the terminal, if you navigate into a directory/folder with a virtitual environment `pyenv` will **_automatically_** activate it.
>
> This is different than Python's built-in virtual environment functionality.  Python's virtual environments must activated **manually** before using them.  (I'm not lazy, I'm energy efficient.)
>

## Install Pyenv

There are multiple ways to install `pyenv`.  On the Mac, one of the easist ways is to use [Homebrew](https://brew.sh/)

```shell
brew install pyenv
```

## Update `.zshrc`

This is important!

Once `pyenv` is installed, update the `.zshrc` file to include the local `pyenv` path and initialize it.

Add these lines to your `.zshrc` file:

```
# Initialize pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
#
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
```

## Remove the existing Homebrew Python

If you've used Homebrew to install Python, remove it. 

```shell
brew uninstall python
```

When there are installed packages that require Python, Homebrew will return an error like this:

```shell
Error: Refusing to uninstall /opt/homebrew/Cellar/python@3.12/3.12.4
because it is required by ... which are currently installed.
You can override this and force removal with:
  brew uninstall --ignore-dependencies python
```

Override the error with this command:

```shell
brew uninstall --ignore-dependencies python
```

## Use Pyenv to Install Python

It's a blessing and a curse that Python has regular update cycles.  

One of Homebrew's **_best features_** is `brew upgrade`.  It does everything for me.

To install Python using Pyenv, you need to know the version number.

### Get the latest Python version using Pyenv

Use `pyenv` to list all the available versions and distributions. 

```
pyenv install --list
```

This output of this command is hundreds of lines long.

This command returns the current version number:

```shell
pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' '
```

> [!NOTE]
> s
> Here are the details from that command:
> 
> **`grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$'`**
> 
> MacOS uses the BSD version of `grep`. The `-E` argument is for extended regular expressions.
> The `regex` returns all of the numbered versions.
> 
> **`tail -1`**
> |
> To get the last entry of the list: `tail -1`
> 
>  **`tr -d ' '`**
> '
> The `-d` argument for `tr` is used to delete any spaces.

## Create a Shell Variable

```shell
export LATEST_VERSION=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ') && echo $LATEST_VERSION
```

Adding `&& echo $LATEST_VERSION` displays the value of the shell variable after the command completes successfully.

## Install the latest Python version with Pyenv

```shell
pyenv install $LATEST_VERSION
```

You _might_ get a message that says something like this:

```text
pyenv: /Users/stephen/.pyenv/versions/3.12.4 already exists
continue with installation? (y/N)
```

Respond with: `y`  

An example of the output that followed:

```text
python-build: use openssl@3 from homebrew
python-build: use readline from homebrew
Downloading Python-3.12.4.tar.xz...
-> https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tar.xz
Installing Python-3.12.4...
python-build: use readline from homebrew
python-build: use ncurses from homebrew
python-build: use zlib from xcode sdk
Installed Python-3.12.4 to /Users/stephen/.pyenv/versions/3.12.4
```

## Make the newly installed Python the global default

```shell
pyenv global $LATEST_VERSION && python --version
```

**Trust But Verify**

```text
❯ python
Python 3.12.4 (main, Jul 14 2024, 09:56:25) [Clang 15.0.0 (clang-1500.3.9.4)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

Seeing this prompt often makes me think of this:

```text
ZORK I: The Great Underground Empire
Copyright (c) 1981, 1982, 1983 Infocom, Inc. All rights reserved.
ZORK is a registered trademark of Infocom, Inc.
Revision 88 / Serial number 840726

West of House
You are standing in an open field west of a white house, with a boarded front door.
There is a small mailbox here.

>
```

## Update pip

Previously, when trying to use `pip` to update Python packages, the PEP 668 warning appeared.

The errors are gone and, as a bonus, you can actually update `pip`.

Update `pip`:

```shell
pip install --upgrade pip
```

## Next steps

Since the old version of Python is gone and a new (global) virtual environment is in place, previously used Python packages must be reinstalled.

## Create an Auto Update Script

Automation improves efficiency and minimizes errors.  Create your own scrips or, use mine:

### bash

[https://github.com/mysticole928/python/blob/main/MacOS/update-python-bash.sh](https://github.com/mysticole928/python/blob/main/MacOS/update-python-bash.sh)

### zsh

[https://github.com/mysticole928/python/blob/main/MacOS/update-python-zsh.sh](https://github.com/mysticole928/python/blob/main/MacOS/update-python-zsh.sh)

## Creating Separate Python Virtual Environment

Use Homebrew to install `pyenv-virtualenv`.  This is a plug-in that automatally activates when you cd into the directory and deactivates it when you leave it.

```shell
brew install pyenv-virtualenv
```

## Create Python Virtual Environments

To create a python vitural environment, the command is `pyenv virtualenv`.

From the command: `pyenv virtualenv --help`

```shell
Usage: pyenv virtualenv [-f|--force] [VIRTUALENV_OPTIONS] [version] <virtualenv-name>
       pyenv virtualenv --version
       pyenv virtualenv --help
```

In the appropriate directory, create the python virtual environment:

```shell
pyenv virtualenv [python-version-number] <virtualenv-name>
```

By default, `pyenv` uses the currently active Python version otherwise, specify the desired version.

The Python version must already be installed using pyenv. If not, install it first:.  For example:

Give the viritual environment a name.  When the name is missing, `pyenv` will use the version number as the name.  

It’s generally a good idea to provide a custom name for virtual environments, especially if you plan to use multiple environments based on the same Python version. 

Custom names make it easier to differentiate between environments and avoid confusion.

```
pyenv install <version>
```

## Run `pyenv local <virtualenv-name>`

```shell
pyenv local <virtualen-name>
```

The command `pyenv local <virtualenv-name>` creates a `.python-version` file in the current directory.  This file contains the Python version or virtual environment to use when working in that directory and takes precedence over global settings from `pyenv global`.




