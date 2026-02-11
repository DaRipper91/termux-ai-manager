# Termux AI Manager

An AI-powered system maintenance tool for Termux - your intelligent assistant for keeping your Termux environment healthy and optimized.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![Platform](https://img.shields.io/badge/platform-Termux-orange.svg)

## Features

- 🖥️ **System Information** - Display detailed device, CPU, memory, and storage information
- 📊 **Resource Monitoring** - Real-time CPU and memory usage with visual progress bars
- 🤖 **AI Diagnostics** - Intelligent system analysis with actionable recommendations
- 🧹 **System Cleanup** - Clean cache, temp files, logs, and unused packages
- 📦 **Package Updates** - Update all system packages with one command
- 🔧 **Package Manager** - Add, remove, search, and manage custom packages
- 📝 **Logging** - Comprehensive logging of all maintenance activities

## Requirements

The tool uses **nala** as the preferred package manager (falls back to apt/pkg if unavailable).

Core dependencies (automatically checked on startup):
- `nala` - Enhanced apt frontend
- `bc` - Mathematical calculations
- `coreutils` - Core system utilities
- `ncurses-utils` - Terminal utilities
- `procps` - Process utilities
- `findutils` - File search utilities
- `grep`, `sed`, `gawk` - Text processing

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/DaRipper91/termux-ai-manager.git

# Navigate to the directory
cd termux-ai-manager

# Make the script executable
chmod +x src/termux-ai-manager.sh

# Run the tool
./src/termux-ai-manager.sh
```

### Add to PATH (Optional)

```bash
# Create a symlink in Termux bin directory
ln -s "$(pwd)/src/termux-ai-manager.sh" "$PREFIX/bin/termux-ai-manager"

# Now you can run from anywhere
termux-ai-manager
```

## Usage

### Interactive Mode (Default)

```bash
./src/termux-ai-manager.sh
# or
./src/termux-ai-manager.sh menu
```

This opens an interactive menu with all available options.

### Command Line Interface

```bash
# Display system information
./src/termux-ai-manager.sh info

# Monitor system resources
./src/termux-ai-manager.sh monitor

# Run AI-powered diagnostics
./src/termux-ai-manager.sh diagnose

# Clean system cache and temporary files
./src/termux-ai-manager.sh clean

# Update system packages
./src/termux-ai-manager.sh update

# Run full maintenance (clean + update + diagnose)
./src/termux-ai-manager.sh maintain

# View maintenance logs
./src/termux-ai-manager.sh logs

# Show help
./src/termux-ai-manager.sh help

# Show version
./src/termux-ai-manager.sh version
```

## Interactive Menu Options

```
========================================
  Termux AI Manager v1.0.0
========================================

  1) System Information
  2) Resource Monitor
  3) AI Diagnostics
  4) System Cleanup
  5) Update System
  6) Full Maintenance (Clean + Update + Diagnose)
  7) Package Manager
  8) View Logs
  9) Help
  0) Exit
```

## Package Management

The tool supports managing additional packages beyond the core requirements:

1. **List Requirements** - View all core and user-added packages with installation status
2. **Add Package** - Add a new package to your requirements and optionally install it
3. **Remove Package** - Remove a package from your requirements and optionally uninstall it
4. **Install All** - Install all packages from requirements.txt and user requirements
5. **Search Packages** - Search for available packages in the repository

User-added packages are stored in `~/.config/termux-ai-manager/user_requirements.txt`

## Configuration

Configuration files are stored in `~/.config/termux-ai-manager/`:

- `maintenance.log` - Log file for all operations
- `ai_suggestions.json` - Last AI diagnostics results in JSON format
- `user_requirements.txt` - User-added package requirements

## Credits

This project is inspired by and builds upon the work of:

- **[Termux Project](https://github.com/termux/termux-tools)** (GPL-3.0 License)
  - System information and backup concepts from termux-info and termux-backup scripts
  - Copyright (c) 2016-2024 Termux

- **[laraib07/TermuxBackupTools](https://github.com/laraib07/TermuxBackupTools)** (MIT License)
  - Backup/restore functionality concepts

- **Termux Community**
  - Various system maintenance patterns and best practices

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**B.Rooster (DaRipper91)**

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/DaRipper91/termux-ai-manager/issues) on GitHub.
