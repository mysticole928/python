# Python 3, MacOS, Homebrew, and PEP 668

Created: 2024-07-15

Edited: 2024-08-06
- Fixed a couple of typos
- Lamented that some of this should be clearer.  A future version of me will rewrite it.
- That future version of me will also create a second document that outlines the steps without the rants.
- The today version of me wants to do it now but there are things that need my attention.
- Speaking of things... Squirrel!

Edited: 2025-01-02 Edited to improve grammar and fix workflow.  (More edits are needed.)

## The Python Message of Doom

As Python coders go, I am a hobbiest.

My code automates tasks and--usually/hopefully--does one or two things well.

For years, I have enjoyed Homebrew'sstallation of Python3 because it let me install
and update Python without worrying if I was going to break the OS.

After the most recent MacOS udpate, Python broke.

That is, when I tried to install a module I got a scary message:

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
> ## Am I the punchline of a joke?
> 
> Paraphrasing the end of that joke: Everything you told me is technically correct and accurate but things are still unclear
> and I have no clue what steps I need to take.
>
> My feeling: I am still lost.

Based on what I've researched, I'm supposed to use a vitual environment, a `venv`.

However, I thought Homebrew's install _was_ a virtual environment. 

I was wrong.

I have a couple of projects that are specialized but I don't really want to have to
create a `venv` for every one of them. 

I could, I suppose, but it's a lot of effort.  Creating virtual environments is a multi-step
process.  They have to be activated individually.

## The Fix: Pyenv

Some of the search results about what to do reference `pyenv` but none of them really explained
what it is, how it works, or what it does. 

There are other options available too. The common ones were Anaconda, Miniconda, and Rye.

Still, there are many websites that try to explain how to install and use `pyenv`.

By explain, it feels like someone is walking me through an arithmetic problem using calculus.

For example: <a href="https://realpython.com/intro-to-pyenv/" target="_blank">Real Python: Managing Multiple Python Versions With pyenv</a>

> [!WARNING]
>
> GitHub Flavored Markdown does not support creating links that open in new windows or tabs.
>
> What year is this?  Do their doctors still use leaches to heal the sick?  Are they afraid
> that they might break the Netscape Navigator experience?  Or, worse, force someone to upgrade
> from Internet Explorer 4?

Anyway, this walkthrough is probably too long.  However, it is--mostly--direct and helpful.  
_At least until it isn't.__

The process of installing and using `pyenv` _can_ be complex **but** it is **not** complicated.

Especially on the Mac.  With Homebrew.

To be fair, there's NO date on that page from Real Python.  (That's more common online than it
probably should be. hough, that's why this walkthough exists.  Yea, me!)

Still, the list of available versions on the Real Python page stop at 3.7.2.  

It also says that `pyenv` is not supported on Windows.  

Hm?  `pyenv-win 3.1.1` has a release date of July 20th, 2022.

<a href="https://pypi.org/project/pyenv-win/" target="_blank">pyenv-win 3.1.1</a>

Today, the version I installed on my Mac is 3.12.4.  

:man_shrugging:

> [!TIP]
>
> **What is Pyenv**
>
> Pyenv is a tool that lets people switch between Python versions easily.
> 
> It also creates a global (machine-wide) python virtual environment.
> (Which addresses PEP 668.)
>
> For those people that work alone and never share anything, that's all you need.
>
> However, `pyenv` can also create individual virtual environments for Python.
> And, in the terminal, if you navigate into a directory/folder with a virtitual environment,
> `pyenv` will **_automatically_** activate it.
>
> This is different than Python's built-in virtual environment functionality.
> The built-in virtual environments must activated **manually** before using them.
>
> Friction prevents adoption.

## Install Pyenv

Start with [Homebrew](https://brew.sh/) and install `pyenv`.

If you're like me, you already have it.  If not, you should get it.  

```shell
brew install pyenv
```

## Update `.zshrc`

This is important!

Once `pyenv` is installed, update the `.zshrc` file to include the local `pyenv` path
and initialize it.

```shell
export PATH="$HOME/.pyenv/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
```

## Remove the existing Homebrew Python

For fans of [Marie Kondo](https://konmari.com/) and her book, _The Life-Changing_
_Magic of Tidying Up: The Japanese Art of Decluttering and Organizing_, give
thanks to Homebrew Python and remove it.

```shell
brew uninstall python
```

When there are installed packages that require Python, there might be an error like this:

```shell
Error: Refusing to uninstall /opt/homebrew/Cellar/python@3.12/3.12.4
because it is required by ... which are currently installed.
You can override this and force removal with:
  brew uninstall --ignore-dependencies python
```

This sounds frightening (_because it is_) but this current implementation of
python is currently suboptimal.  (Read: It's broken.)

```shell
brew uninstall --ignore-dependencies python
```

## Use Pyenv to Install Python

It's a blessing and a curse that Python has regular update cycles.  

One of Homebrew's **_best features_** is `brew upgrade`.  It does everything for me.

To install Python using Pyenv, you need to know the version number.

I've figured out a neat trick to getting the latest version number without having to explore the web.

### Get the latest Python version using Pyenv

Use `pyenv` to list all the available versions and distributions. 

The command is `pyenv install --list`. 

This output of this command is long.  I ran: `pyenv install --list | wc -l`
and the number was 825.  

To get the most recent version, pipe the results of `pyenv install --list` to `grep -E` to use
some `regex` magic.  This expression `'^\s*[0-9]+\.[0-9]+\.[0-9]+$'` returns a list of the Python
verions numbers.  

Pipe that out through `tail -1` to get the last one.

Then, pipe _that_ output through `tr -d ' '` to remove the spaces.

Here's the full command.

```shell
pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' '
```

**Command output:** `3.12.4`

To make life easier (automation == efficieny), assign it to a shell variable.

```shell
export LATEST_VERSION=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
```

**Trust but verify:**

This is the exact same command as above _and_ it includes validation of the output.

```shell
export LATEST_VERSION=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ') && echo $LATEST_VERSION
```


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
pyenv global $LATEST_VERSION
```

## Trust but verify

```shell
python --version
```

**Command output:** `Python 3.12.4`

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

**Command output:**

```text
❯ pip install --upgrade pip
Requirement already satisfied: pip in /Users/stephen/.pyenv/versions/3.12.4/lib/python3.12/site-packages (24.0)
Collecting pip
  Using cached pip-24.1.2-py3-none-any.whl.metadata (3.6 kB)
Using cached pip-24.1.2-py3-none-any.whl (1.8 MB)
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 24.0
    Uninstalling pip-24.0:
      Successfully uninstalled pip-24.0
Successfully installed pip-24.1.2
```

## Next steps

Since the old version of Python is gone and a new (global) virtual
environment is in place, Python packages must be reinstalled.

For example, when I tried to run some python code that used `pandas`, I got a
message sayint it wasn't installed.

## Create an Auto Update Script

I've already done this for you.  It uses all the features desribed so far to automate the process.

It's in this GitHub repository.  Though, here's a link:

### bash

[https://github.com/mysticole928/python/blob/main/MacOS/update-python-bash.sh](https://github.com/mysticole928/python/blob/main/MacOS/update-python-bash.sh)

### zsh

[https://github.com/mysticole928/python/blob/main/MacOS/update-python-zsh.sh](https://github.com/mysticole928/python/blob/main/MacOS/update-python-zsh.sh)


## When you NEED a Separate Python Environment

There may be times that separate python versions are needed.  Pyenv can manage
them.  First, install `pyenv-virtualenv` using Homebrew.

## Install `pyenv-virtualenv`

```shell
brew install pyenv-virtualenv
```

** This was updated to use `zsh` **

After it's been installed, update the `#Initialize pyenv` section of your `.zshrc` 
file and add this line: `eval "$(pyenv virtualenv-init -)"`

The complete code block should look like this:

```shell
# Initialize pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
```

## To Create a Python Virtual Environments

To create a python vitural environment, the command is `pyenv virtualenv`.

```shell
cd /path/to/the/python/project

pyenv virtualenv 3.10.11 project-name-env  # Replace 3.10.11 with the required Python version

pyenv local project-name-env
```

> [!TIP] `pyenv local` vs `venv activate`
>
> `pyenv local` and `venv activate` both activate a specific Python environment for a project.
>
> However, they do it in different ways and with different tools.
>
> **`pyenv local`**
>
> `pyenv local` sets the Python version for the current directory and all its subdirectories.
>
> It creates a `.python-version` file with the specified version.
>
> When navigating to the directory where you've run pyenv local, `pyenv` _\*\*automatically_\*\*
> switches to the specified Python version.
>
> **`venv activate`**
>
> `venv` is a built-in Python module that creates virtual environments.
>
> These virtual environments are manually activated by sourcing the `activate` script.
>
> The command looks like this: `source venv/bin/activate`
>
> When a venv environment is activated, it changes the current shell's environment
> to use the virtual environment's Pythonterpreter and packages.

