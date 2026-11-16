# AGENTS.md — termux-ai-manager

## Project Overview
`termux-ai-manager` is an intelligent system maintenance tool and terminal management environment tailored for Android Termux. It provides hardware resource telemetry, system diagnostics, automated cleaning, package updates, and interactive shell setups (including Fish shell installer).

- **Target Platform:** Android Termux (ARM64 / Android 7.0+).
- **Core Executables:**
  - `src/termux-ai-manager.sh` — Primary CLI and interactive maintenance suite.
  - `src/fish-installer.sh` — Interactive Fish shell installer.
- **Test Suite:** `tests/test_cli.py`

---

## Technical Stack & Dependencies
- **Shell:** Bash (Termux standard `/data/data/com.termux/files/usr/bin/bash` with portable `/usr/bin/env bash` fallback).
- **Core Dependencies:** Listed in `requirements.txt`:
  - `nala`, `bc`, `coreutils`, `ncurses-utils`, `procps`, `findutils`, `grep`, `sed`, `gawk`.
- **Testing Engine:** `pytest` (Python 3.10+) executing headless command checks and bash syntax validations.

---

## Agent Guidance & Invariant Rules
- **Canonical Agent Configuration:**
  `AGENTS.md` in the repository root is canonical. `CLAUDE.md`, `GEMINI.md`, and `.cursorrules` are symlinks pointing directly to this file.
- **Path Portability:**
  Scripts must support both Termux directory hierarchies (`/data/data/com.termux/files/...`) and standard Linux host environments for headless CI/testing.
- **Verification Rule:**
  Always execute `pytest tests/` and run `bash -n` syntax checks on all shell scripts before committing.

---

## Verification Runbooks
```bash
# Navigate to repository root
cd /home/daripper/Projects/termux-ai-manager

# Verify shell syntax
bash -n src/termux-ai-manager.sh
bash -n src/fish-installer.sh

# Run automated test suite
pytest tests/

# Test CLI commands
bash src/termux-ai-manager.sh version
bash src/termux-ai-manager.sh help
```
