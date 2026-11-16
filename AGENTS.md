# AGENTS.md — termux-ai-manager

## Project Overview
`termux-ai-manager` (v2.0.0) is the unified flagship system maintenance, terminal environment manager, and Arch Linux PRoot studio for Android Termux. It provides hardware resource telemetry, AI diagnostics, automated cleaning, package updates, Fish shell setup, and full Arch Linux PRoot deployment.

- **Target Platform:** Android Termux (ARM64 / Android 7.0+).
- **Core Executables:**
  - `src/termux-ai-manager.sh` — Primary CLI (`tam`) and interactive maintenance suite.
  - `src/fish-installer.sh` — Interactive Fish shell installer.
  - `tools/universal_installer.py` & `tools/arch-installer/` — Arch Linux PRoot container studio.
- **Test Suite:** `tests/test_cli.py`, `tests/test_tools_utils.py`

---

## Technical Stack & Dependencies
- **Shell:** Bash (Termux standard `/data/data/com.termux/files/usr/bin/bash` with portable `/usr/bin/env bash` fallback).
- **Python:** Python 3.10+ (for tools and automated testing).
- **Core Dependencies:** Listed in `requirements.txt`:
  - `nala`, `bc`, `coreutils`, `ncurses-utils`, `procps`, `findutils`, `grep`, `sed`, `gawk`, `proot`.
- **Testing Engine:** `pytest` (Python 3.10+) executing headless command checks, Python utility unit tests, and bash syntax validations.

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
bash src/termux-ai-manager.sh arch
```
