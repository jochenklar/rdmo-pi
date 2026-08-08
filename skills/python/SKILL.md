---
name: python
description: "Use this skill for any task that may run Python, create or modify `.py` files, install or inspect Python packages, or reason about the Python environment in this container. Trigger for ad-hoc `python`/`python3` commands; Also trigger before creating any virtual environment or choosing an interpreter. Never create a new venv: use the preconfigured environment directly."
---

# Python environment

This container has a pre-configured Python environment. Use it directly — do not create new venvs, do not use `--user` installs, do not use `--break-system-packages`.

## Required first check

Before the first Python command or package operation, verify the active environment when it has not already been established in the current task:

```bash
echo "$VIRTUAL_ENV"
ls -l /opt/env/bin/python
```

Expect `VIRTUAL_ENV` to be `/opt/env` and the interpreter at `/opt/env/bin/python`. The environment's `bin` directory may not be on `PATH`, so `python` may not resolve even though the environment is configured; invoke the interpreter by its absolute path. Do not create `.venv`, `venv`, `env`, or another environment; use the existing `/opt/env`. If a repository's instructions request a separate venv, report the conflict and continue with the preconfigured environment unless the user explicitly directs otherwise.

## Running Python

Use the preconfigured interpreter explicitly:

```bash
/opt/env/bin/python script.py
```

It is managed by uv; run `/opt/env/bin/python --version` if the exact version matters. Do not use `/usr/bin/python3`; that is the system interpreter.

## Installing packages

Use `uv pip`, not plain `pip`. It's faster and installs into the active venv automatically:

```bash
uv pip install <package>
uv pip install -r requirements.txt
uv pip uninstall <package>
uv pip list
```

Explicitly target the preconfigured interpreter: `uv pip <command> --python /opt/env/bin/python ...`. Plain `pip` also works but is slower.

## What NOT to do

- Don't run `python3 -m venv ...` — the venv already exists at `/opt/env`.
- Don't run `python -m venv`, `virtualenv`, `uv venv`, or environment-creation tools under another spelling.
- Don't create a project-local environment merely to isolate dependencies.
- Don't run `pip install --user` — it installs outside the venv and won't be importable.
- Don't run `sudo pip install` or `pip install --break-system-packages` — bypasses the venv entirely.
- Don't run `uv run --with <package>` for one-offs unless you have a reason — `uv pip install <package>` once and use it normally is simpler for a persistent container.
- Don't run `apt install python3-<something>` — those go to the system Python, which the agent doesn't use.

## Verifying the environment

If anything looks off:

```bash
/opt/env/bin/python --version
uv pip list --python /opt/env/bin/python
```
