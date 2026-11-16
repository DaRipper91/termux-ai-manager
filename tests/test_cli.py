import subprocess
import os
import pytest

SCRIPT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src"))
MAIN_SCRIPT = os.path.join(SCRIPT_DIR, "termux-ai-manager.sh")
FISH_INSTALLER = os.path.join(SCRIPT_DIR, "fish-installer.sh")

def test_bash_syntax_validity():
    res1 = subprocess.run(["bash", "-n", MAIN_SCRIPT], capture_output=True, text=True)
    assert res1.returncode == 0, f"Syntax error in termux-ai-manager.sh: {res1.stderr}"

    res2 = subprocess.run(["bash", "-n", FISH_INSTALLER], capture_output=True, text=True)
    assert res2.returncode == 0, f"Syntax error in fish-installer.sh: {res2.stderr}"

def test_version_command():
    res = subprocess.run(["bash", MAIN_SCRIPT, "version"], capture_output=True, text=True)
    assert res.returncode == 0
    assert "Version:" in res.stdout
    assert "2.0.0" in res.stdout
    assert "B.Rooster <DaRipper>" in res.stdout

def test_help_command():
    res = subprocess.run(["bash", MAIN_SCRIPT, "help"], capture_output=True, text=True)
    assert res.returncode == 0
    assert "USAGE:" in res.stdout
    assert "COMMANDS:" in res.stdout
    assert "diagnose" in res.stdout
    assert "arch" in res.stdout

def test_arch_command_invocation():
    # Calling with input to avoid hanging if it prompts
    res = subprocess.run(["bash", MAIN_SCRIPT, "arch"], input="exit\n", capture_output=True, text=True)
    assert "Arch Linux PRoot Studio" in res.stdout

def test_unknown_command_fails():
    res = subprocess.run(["bash", MAIN_SCRIPT, "nonexistent-cmd"], capture_output=True, text=True)
    assert res.returncode == 1
    assert "Unknown command: nonexistent-cmd" in res.stdout or "Unknown command: nonexistent-cmd" in res.stderr
